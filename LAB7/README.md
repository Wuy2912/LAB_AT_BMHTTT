# BÁO CÁO LAB 7: XÂY DỰNG CHÍNH SÁCH WEB PROTECTION TRÊN MÔ HÌNH pfSense + WEB PROXY

## 1. Thông tin sinh viên
- **Họ và tên:** Nguyễn Dương Quốc Huy
- **MSSV:** [Nhập MSSV của bạn vào đây]
- **Tên Lab:** LAB 7 - Xây dựng chính sách Web Protection trên mô hình Firewall pfSense và Web Proxy độc lập.

---

## 2. Phiên bản môi trường
Hệ thống được ảo hóa trên VMware Workstation với cấu hình ép xung RAM để tối ưu tài nguyên:
- **Tường lửa (pfSense):** 2.7.2-RELEASE (512MB RAM)
- **Domain Controller (DC01):** Windows Server 2025 (2GB RAM)
- **Client-A:** Windows 10 (2GB RAM)
- **DMZ-WEB:** Ubuntu Server 24.04 LTS (512MB RAM)
- **WEB-PROXY:** Ubuntu Server 24.04 LTS (1GB RAM)

---

## 3. Cách dựng môi trường (Tiến độ thực tế)
Quá trình xây dựng hệ thống đã được triển khai đến bước thiết lập mạng cho Proxy:
1. **Dựng DMZ-WEB (172.16.6.10):** Dùng tính năng VMware Shared Folders để đưa tài nguyên vào máy ảo. Chạy thành công script Bash tạo Nginx với 13 Virtual Hosts (`.lab7.test`).
2. **Dựng Hệ thống DNS (DC01 - 10.6.0.10):** Bypass Execution Policy và chạy script PowerShell. Tạo thành công Zone `lab7.test` và phân giải hoàn tất về IP `172.16.6.10` (Đã test thành công lệnh `Resolve-DnsName` trên Client-A).
3. **Khởi tạo WEB-PROXY (10.6.0.30):** 
   - Đã tạo VM mới và gắn IP tĩnh thông qua file `/etc/netplan/99-custom.yaml`.
   - Đã ép đường dẫn Gateway và DNS (8.8.8.8).
   - Đã tạo Rule trên cổng LAN của pfSense cho phép IP `10.6.0.30` đi ra Internet.
4. **Trạng thái dừng:** Máy ảo WEB-PROXY không thể kết nối ra Internet để tải các gói phần mềm lõi (`squid`, `e2guardian`, `clamav`). Quá trình cấu hình chính sách Web Protection không thể tiếp tục.

---

## 4. Các tình huống đã thực hiện & Kết quả

| STT | Kịch bản / Loại trang web | Đích kiểm thử (Domain) | Kết quả thực tế |
|:---:|:---|:---|:---:|
| 1 | **Phân giải DNS nội bộ** | normal.lab7.test | **PASS** (Client-A nhận diện đúng IP 172.16.6.10) |
| 2 | **Baseline (Trang hợp lệ)** | normal.lab7.test | **CHƯA THỰC HIỆN** (Do Proxy chưa cài đặt) |
| 3 | **Geo-Sim (Chặn vùng địa lý)** | china.lab7.test, mideast... | **FAIL** / Bỏ qua |
| 4 | **Job Search** | jobs.lab7.test | **FAIL** / Bỏ qua |
| 5 | **Warning Content (Cảnh báo)** | weapons/politics/religion... | **FAIL** / Bỏ qua |
| 6 | **Education (Giáo dục)** | education.lab7.test | **FAIL** / Bỏ qua |
| 7 | **Entertainment/Game** | entertainment / games... | **FAIL** / Bỏ qua |
| 8 | **Streaming** | streaming.lab7.test | **FAIL** / Bỏ qua |
| 9 | **Antivirus (Quét mã độc)** | download.../eicar.com.txt | **FAIL** / Bỏ qua |

---

## 5. Lỗi gặp phải và Cách khắc phục
Trong quá trình triển khai, hệ thống gặp một số lỗi và đã cố gắng khắc phục theo từng bước:

* **Lỗi 1: Không thể copy file/thư mục từ máy thật vào các máy ảo (Kéo thả/Copy Paste không hoạt động).**
  * *Cách khắc phục:* Đã xử lý thành công bằng tính năng **VMware Shared Folders**. Mount thư mục host thẳng vào `/mnt/hgfs` trên Ubuntu và truy cập qua `\\vmware-host\Shared Folders` trên Windows Server.

* **Lỗi 2: Lệnh script tạo DNS bị chặn trên DC01 (UnauthorizedAccess).**
  * *Cách khắc phục:* Chạy lệnh `Set-ExecutionPolicy Bypass -Scope Process -Force` trên PowerShell để gỡ bỏ chính sách bảo mật tạm thời, giúp script phân giải DNS chạy thành công.

* **Lỗi 3: Cấu hình IP tĩnh cho WEB-PROXY bằng Netplan báo lỗi `Permissions are too open`.**
  * *Cách khắc phục:* Đã sử dụng lệnh `sudo chmod 600 /etc/netplan/99-custom.yaml` để thắt chặt quyền đọc/ghi file và nạp lại bằng `sudo netplan apply`. Lệnh `ip a` đã nhận IP 10.6.0.30 thành công.

* **Lỗi 4 (LỖI NGHIÊM TRỌNG): WEB-PROXY mất kết nối Internet hoàn toàn, tiến trình `apt update` bị treo.**
  * *Hiện tượng:* Lệnh `ping google.com` bị treo, lệnh `ping 8.8.8.8` báo `100% packet loss` dù đã tạo rule Pass trên pfSense.
  * *Chuẩn đoán:* Card mạng NAT (WAN) của VMware cấp cho pfSense bị lỗi định tuyến (Routing issue) hoặc kẹt bảng trạng thái, khiến các gói tin từ mạng LAN ảo không thể dịch địa chỉ (Outbound NAT) ra ngoài máy thật.
  * *Biện pháp đã thử nhưng thất bại:* 
    1. Đã ép thủ công route/gateway (`ip route add default via 10.6.0.1`).
    2. Đã ép thủ công DNS vào `/etc/resolv.conf`.
    3. Đã Reboot toàn bộ hệ thống pfSense từ màn hình console.
  * *Kết luận:* Sự cố hạ tầng ảo hóa chưa thể khắc phục ngay, dẫn đến việc không thể tải bộ ba phần mềm lõi (Squid, E2guardian, ClamAV). Quá trình xây dựng bài Lab buộc phải dừng lại ở giai đoạn thiết lập IP.
