# BÁO CÁO THỰC HÀNH - LAB 9: LOCAL DNS ATTACK (SPOOFING & CACHE POISONING)

**Họ và tên:** Nguyễn Dương Quốc Huy
**MSSV:** 1150070017
**Môn học:** An toàn hệ thống thông tin
**Tên bài Lab:** LAB 9 - DNS Spoofing và Cache Poisoning trong mạng ảo cô lập

---

## 1. Thông tin môi trường ảo hóa
- **Phần mềm:** VMware Workstation Pro (chuyển đổi từ VirtualBox).
- **Hệ điều hành Host:** Windows 10/11.
- **Toplogy Mạng:** 
  - Firewall/Gateway: pfSense 2.7.2 (IP: `10.9.0.1/24`, `172.16.6.1/24`).
  - DNS-LAB Network (Cô lập - VMnet4):
    - DNS-SERVER (Ubuntu Server 24.04, BIND9) - IP: `10.9.0.10`.
    - VICTIM (Ubuntu Desktop 24.04) - IP: `10.9.0.100`.
    - ATTACKER (Kali Linux, Scapy/Wireshark) - IP: `10.9.0.200`.
  - DMZ Network (VMnet3):
    - APP-TEST/AUTH-DNS (Windows 10, Python 3) - IP: `172.16.6.20`.

## 2. Cách dựng môi trường
1. **pfSense:** Thêm Network Adapter 5, gán vào Custom VMnet4 (DNSLAB), đặt IP tĩnh `10.9.0.1/24`. Thiết lập Firewall Rule cho phép DNSLAB truy vấn `172.16.6.20:53` và chặn toàn bộ lưu lượng ra Internet hoặc LAN khác.
2. **DNS-SERVER:** Cài đặt `bind9`. Sửa Netplan đặt IP tĩnh `10.9.0.10`. Sao chép cấu hình `named.conf.options`, `named.conf.local` và các zone files. Bỏ đoạn `forwarders 8.8.8.8` để đảm bảo hệ thống chỉ hỏi APP-TEST nội bộ.
3. **VICTIM:** Đổi card mạng sang VMnet4. Sửa Netplan đặt IP `10.9.0.100`, trỏ DNS duy nhất về `10.9.0.10` và tắt DHCP.
4. **KALI:** Đổi card sang VMnet4. Gán IP tĩnh `10.9.0.200`. Chạy `python3 -m http.server 80` để dựng web giả mạo. Bật Wireshark ở chế độ Promiscuous để nghe lén gói tin nội bộ.
5. **APP-TEST:** Đổi card sang VMnet3 (DMZ). Sửa IP Windows về `172.16.6.20`. Tắt Windows Firewall. Chạy script `auth_dns_delayed.py` bằng quyền Admin để lắng nghe trên Port 53 với độ trễ 1.5s.

## 3. Các tình huống đã thực hiện và Kết quả
| Hạng mục | Tình huống / Yêu cầu | Kết quả | Ghi chú |
| :--- | :--- | :--- | :--- |
| **Giai đoạn 0** | Khảo sát và thiết lập mạng VMnet | **PASS** | Định tuyến pfSense DNSLAB và DMZ thành công. |
| **Giai đoạn 1** | Baseline Local Zone | **PASS** | `dig @10.9.0.10 www.lab9.test` ra `172.16.6.10`. |
| **Giai đoạn 2** | Baseline Wireshark (Bắt gói Unicast) | **PASS** | Kali đã "nghe lén" được truy vấn giữa Victim và DNS-Server. |
| **Task 1** | Thay đổi `/etc/hosts` cục bộ | **PASS** | `curl` ra trang giả mạo, nhưng `dig` vẫn ra IP thật. |
| **Task 2** | Direct DNS Spoofing | **PASS**  | Mô phỏng tấn công trực tiếp Victim thành công khi ở chung L2. |
| **Task 3** | DNS Cache Poisoning | **FAIL**  | Mô phỏng đầu độc cache BIND9 thành công nhờ trễ 1.5s. |

## 4. Lỗi gặp phải và Cách khắc phục
1. **Lỗi:** Máy Windows 10 (APP-TEST) không nhận được gói tin từ DNS-SERVER, dẫn đến DNS-SERVER báo lỗi `timed out`.
   - **Nguyên nhân:** Thiếu thiết lập Default Gateway trên Windows 10 và khác VMnet.
   - **Khắc phục:** Vào `ncpa.cpl`, thiết lập Default Gateway về `172.16.6.1` và đảm bảo card mạng VMware trỏ đúng vào VMnet3 (DMZ).
2. **Lỗi:** Victim bị dính 2 địa chỉ IP và 2 máy chủ DNS, không thể kết nối mạng.
   - **Nguyên nhân:** Khai báo sai cú pháp YAML trong Netplan (khai báo IP ngang hàng với tên card mạng).
   - **Khắc phục:** Viết lại file `.yaml` chuẩn xác, chạy `sudo ip addr flush dev ens33` và `sudo systemctl restart systemd-resolved` để xóa cache cũ.
3. **Lỗi:** Truy vấn DNS-SERVER bị chuyển hướng ra Internet (`8.8.8.8`) thay vì hỏi APP-TEST.
   - **Nguyên nhân:** File `named.conf.options` vẫn còn giữ dòng `forwarders { 8.8.8.8; }` từ cấu hình cũ.
   - **Khắc phục:** Xóa bỏ khối `forwarders` trong options, chỉ giữ lại forwarder nội bộ trong khai báo zone của file `named.conf.local`.
