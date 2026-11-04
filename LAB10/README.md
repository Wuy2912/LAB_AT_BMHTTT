# LAB 10 – REMOTE DNS CACHE POISONING TRONG MÔI TRƯỜNG pfSense CÔ LẬP

## 1. Thông tin sinh viên
- **Họ và tên:** Nguyễn Dương Quốc Huy
- **MSSV:** 1150070017
- **Tên bài thực hành:** LAB 10 – Remote DNS Cache Poisoning trong môi trường pfSense cô lập
- **Học phần:** Thực hành An toàn Hệ thống Thông tin
- **Ngày thực hiện:** 04/11/2026

---

## 2. Phiên bản môi trường và Công cụ sử dụng
- **Phần mềm ảo hóa:** VMware Workstation Pro (chuyển đổi từ mô hình VirtualBox Internal Network sang các nhánh Custom `VMnet` cô lập hoàn toàn).
- **Tường lửa / Router trung tâm:** pfSense Firewall (`1150070017_NguyenDuongQuocHuy_pfSense`) quản lý các phân vùng mạng:
  - `WAN`: `192.168.192.130` (DHCP/NAT)
  - `MGMT`: `192.168.101.254/24` (Mạng quản trị WebGUI)
  - `LAN`: `10.6.0.1/24` (Mạng LAN-DOMAIN của LAB 7/8 – được bảo vệ cô lập)
  - `DMZ`: `172.16.6.1/24` (Chứa `DMZ-WEB` và `AUTH-DNS/RELAY`)
  - `DNSLAB`: `10.9.0.1/24` (Chứa `DNS-SERVER` và `VICTIM`)
  - `ATTACKNET`: `10.10.0.1/24` (Nhánh mạng riêng biệt dành cho `ATTACKER Kali`, không gán Upstream Gateway)
- **Hệ điều hành và Dịch vụ trên các máy ảo:**
  - `DNS-SERVER` (`10.9.0.10/24` – Ubuntu Server): Chạy **ISC BIND 9.18** (pha Baseline & Hardening) và script **`vuln_resolver_lab10.py`** (pha mô phỏng Resolver có cổng nguồn UDP cố định `33333`).
  - `VICTIM` (`10.9.0.100/24` – Windows 10 / Ubuntu Client): Máy trạm DNS Client trỏ DNS về `10.9.0.10`.
  - `ATTACKER Kali` (`10.10.0.200/24` – Kali Linux): Chạy **`evil_dns_lab10.py`** (`UDP 53`), **`python3 -m http.server 80`** (`TCP 80`) và **`kaminsky_remote_lab10.py`**.
  - `AUTH-DNS / RELAY (APP-TEST)` (`172.16.6.20/24` – Ubuntu Server): Chạy **`auth_dns_relay_lab10.py`** (Authoritative DNS trên `UDP 53` và TXID Race Harness trên `UDP 5300`).
  - `DMZ-WEB` (`172.16.6.10/24`): Máy chủ Web hợp lệ phục vụ tên miền thử nghiệm `http://www.example.lab10.test`.
- **Tên miền kiểm thử an toàn:** `example.lab10.test` (theo chuẩn RFC 2606).

---

## 3. Cách dựng môi trường (Step-by-Step)
1. **Thêm nhánh mạng `ATTACKNET` trên pfSense:**
   - Thêm 1 Network Adapter mới trên máy ảo pfSense gắn vào một `Custom VMnet` độc lập.
   - Vào `Interfaces > Assignments` trên WebGUI pfSense, thêm interface mới, đặt tên **`ATTACKNET`**, cấu hình **Static IPv4** là `10.10.0.1/24` và giữ `IPv4 Upstream gateway = None`.
2. **Tách máy `Kali` khỏi `DNS-LAB` sang `ATTACKNET`:**
   - Tháo/chuyển card mạng của máy ảo Kali từ `DNS-LAB` sang đúng `Custom VMnet` của `ATTACKNET` (`Promiscuous Mode = Deny`).
   - Tắt quản lý tự động của NetworkManager trên `eth0` và gán IP tĩnh `10.10.0.200/24`, Gateway `10.10.0.1`:
     ```bash
     sudo nmcli device set eth0 managed no
     sudo ip addr flush dev eth0
     sudo ip addr add 10.10.0.200/24 dev eth0
     sudo ip link set eth0 up
     sudo ip route add default via 10.10.0.1
     ```
3. **Thiết lập Firewall Rules cô lập trên pfSense:**
   - **Tab `DNSLAB`:** Cho phép `10.9.0.100 -> 10.9.0.10` (`TCP/UDP 53`); `10.9.0.10 -> 172.16.6.20` (`UDP 53`); `10.9.0.10 -> 10.10.0.200` (`UDP 53`); `10.9.0.0/24 -> 10.10.0.200` & `172.16.6.10` (`TCP 80`). Chặn và ghi log (`Block + Log`) toàn bộ truy cập sang `LAN (10.6.0.0/24)`, `MGMT (192.168.101.0/24)` và `Any`.
   - **Tab `ATTACKNET`:** Cho phép `10.10.0.200 -> 10.9.0.10` (`TCP/UDP 53`); mở rule tạm thời `10.10.0.200 -> 172.16.6.20` (`UDP 5300` cho Race Relay). Chặn và ghi log (`Block + Log`) toàn bộ kết nối sang `LAN`, `MGMT` và `Any` (không cho phép ra WAN).
   - Thực hiện `Diagnostics > States > Reset States` sau khi áp dụng rule.
4. **Cấu hình Baseline trên `DNS-SERVER` (`10.9.0.10`) và `APP-TEST` (`172.16.6.20`):**
   - Sao lưu cấu hình BIND9 cũ (`.lab9.bak`), nạp cấu hình baseline (giới hạn `allow-recursion` cho `10.9.0.0/24`, forward zone `example.lab10.test` về `172.16.6.20`, bật `dnssec-validation auto` kèm `validate-except` cho `example.lab10.test`).
   - Cài đặt `python3-dnspython` và khởi chạy `sudo python3 auth_dns_relay_lab10.py` trên máy `APP-TEST` (`172.16.6.20`).

---

## 4. Các tình huống đã thực hiện và Kết quả (PASS / FAIL)

| STT | Tình huống thực nghiệm (Test Case) | Mô tả thao tác & Tiêu chí kiểm tra | Kết quả |
| :-: | :--- | :--- | :-: |
| **01** | **Cô lập nhánh mạng `ATTACKNET` và thiết lập Firewall** | Thêm interface `ATTACKNET` (`10.10.0.1/24`), chuyển Kali sang `10.10.0.200/24`, áp dụng đầy đủ Firewall Rules trên `DNSLAB` và `ATTACKNET`. | **PASS** |
| **02** | **Kiểm tra trạng thái chuẩn (Baseline)** | Khởi động BIND9 trên `10.9.0.10` và `auth_dns_relay_lab10.py` trên `172.16.6.20`. Từ `VICTIM` (`10.9.0.100`) truy vấn `www.example.lab10.test` trả về đúng `172.16.6.10` và mở được trang web hợp lệ. | **PASS** |
| **03** | **Chứng minh tính "Remote" (Kali không sniff được `DNSLAB`)** | Chạy `sudo tcpdump -ni any udp port 53` trên Kali trong lúc `VICTIM` truy vấn DNS. Kali ghi nhận `0 packets captured`, không thấy lưu lượng `10.9.0.10 <-> 172.16.6.20`. | **PASS** |
| **04** | **Chuyển sang Resolver mô phỏng (`vuln_resolver_lab10.py`)** | Dừng `bind9` trên `10.9.0.10`, chạy `vuln_resolver_lab10.py` lắng nghe tại `10.9.0.10:53` với cổng nguồn UDP upstream cố định ở `33333`. | **PASS** |
| **05** | **Thực hiện tấn công Remote Cache Poisoning (Kaminsky Simulation)** | Chạy `evil_dns_lab10.py` (`:53`), Fake Web (`:80`) và `kaminsky_remote_lab10.py` trên Kali. Ghi nhận đủ chuỗi log `[PENDING]` -> `[HIT]` (trên `172.16.6.20`) và `[CACHE]` delegation poisoned (trên `10.9.0.10`). | **PASS** |
| **06** | **Phân tích bắt gói (`Packet Capture`) và kiểm tra `VICTIM` sau Poison** | Bắt gói trên `DNS-SERVER` thấy rõ query từ `10.9.0.10:33333` và gói trả lời giả mạo chứa `Authority NS = ns.evil.example.lab10.test` + `Glue A = 10.10.0.200`. Máy `VICTIM` phân giải `www.example.lab10.test` ra `10.10.0.200` và hiển thị Fake Site. | **PASS** |
| **07** | **Khôi phục BIND 9.18, Hardening & Dọn dẹp sau Lab** | Dừng Resolver mô phỏng, bật lại `bind9`. Xác nhận Kali bị từ chối đệ quy (`status: REFUSED`), quan sát cổng nguồn UDP biến thiên ngẫu nhiên (Source-Port Randomization) qua `tcpdump` và tắt rule tạm `UDP 5300`. | **PASS** |

---

## 5. Các lỗi gặp phải trong quá trình thực hiện và Cách khắc phục

1. **Lỗi 1: Gán IP tĩnh `10.10.0.200/24` trên Kali bằng lệnh `ip addr add` nhưng bị tự động mất IP sau vài giây (`Error: Nexthop has invalid gateway`)**
   - **Nguyên nhân:** Dịch vụ `NetworkManager` trên Kali Linux đang quản lý giao diện `eth0` ở chế độ DHCP nên tự động xóa địa chỉ IP gán thủ công khi không tìm thấy DHCP Server trên nhánh `ATTACKNET`.
   - **Cách khắc phục:** Chạy lệnh `sudo nmcli device set eth0 managed no` để ngắt quyền can thiệp tự động của `NetworkManager` trên `eth0`, sau đó gán lại IP `10.10.0.200/24` và default route `10.10.0.1`.

2. **Lỗi 2: Không tìm thấy cổng `5300` trong danh sách Port có sẵn khi tạo Firewall Rule trên pfSense**
   - **Nguyên nhân:** Giao diện cấu hình Rule của pfSense mặc định hiển thị các cổng dịch vụ chuẩn (DNS 53, HTTP 80, HTTPS 443...), không liệt kê sẵn cổng tùy chỉnh `5300` của Race Relay.
   - **Cách khắc phục:** Tại mục `Destination Port Range`, chọn giá trị **`(other)`** ở menu thả xuống rồi nhập trực tiếp số **`5300`** vào ô `Custom` bên cạnh, đồng thời tích bật `Log packets` cho các rule Block.

3. **Lỗi 3: Chạy script `auth_dns_relay_lab10.py` báo lỗi `ModuleNotFoundError: No module named 'dns'`**
   - **Nguyên nhân:** Máy ảo Ubuntu chưa được cài đặt gói thư viện Python hỗ trợ xử lý giao thức DNS (`python3-dnspython`).
   - **Cách khắc phục:** Chạy lệnh `sudo apt update && sudo apt install -y python3-dnspython` để cài đặt đầy đủ thư viện trước khi khởi chạy script.

4. **Lỗi 4: Chạy `auth_dns_relay_lab10.py` báo lỗi `OSError: [Errno 99] Cannot assign requested address`**
   - **Nguyên nhân:** Giao diện mạng `ens33` của máy Ubuntu lúc đó đang mang địa chỉ IP `10.9.0.100/24` (nhánh `DNS-LAB`), trong khi biến `BIND_IP` trong script `auth_dns_relay_lab10.py` được cố định lắng nghe trên địa chỉ `172.16.6.20` (nhánh `DMZ`).
   - **Cách khắc phục:** Chuyển card mạng VMware của máy ảo sang đúng `VMnet` của vùng `DMZ`, tắt quản lý của `nmcli` và gán đúng địa chỉ IP tĩnh `172.16.6.20/24` (Gateway `172.16.6.1`) cho giao diện `ens33` trước khi chạy lại script.

5. **Lỗi 5: Lệnh `nslookup` trên máy trạm Windows 10 hiển thị `Server: UnKnown / Address: fec0:0:0:ffff::1` và báo `No response from server`**
   - **Nguyên nhân:** Card mạng trên Windows 10 đang bật giao thức TCP/IPv6 nên `nslookup` ưu tiên gửi truy vấn DNS qua địa chỉ IPv6 mặc định (`fec0:0:0:ffff::1`) thay vì gửi tới địa chỉ IPv4 của `DNS-SERVER` (`10.9.0.10`).
   - **Cách khắc phục:** Mở `ncpa.cpl`, vào `Properties` của card mạng, bỏ tích `Internet Protocol Version 6 (TCP/IPv6)` và khai báo Preferred DNS Server ở mục IPv4 là `10.9.0.10`.
