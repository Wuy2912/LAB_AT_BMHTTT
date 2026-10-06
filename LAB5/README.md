# Báo cáo Lab 3: Thiết lập mô hình tường lửa pfSense

## 1. Thông tin sinh viên
* **Họ và tên:** Nguyễn Dương Quốc Huy
* **MSSV:** 1150070017
* **Tên Lab:** THỰC HÀNH AN TOÀN HỆ THỐNG THÔNG TIN - Thiết lập mô hình tường lửa pfSense

## 2. Phiên bản môi trường
* **Phần mềm ảo hóa:** VMware Workstation
* **Hệ điều hành Firewall:** pfSense CE 2.7.2-RELEASE (amd64)
* **Hệ điều hành máy chủ LAN/DMZ:** Windows Server 2025
* **Hệ điều hành máy trạm (LAN-Test):** Ubuntu Server 26.04 Minimal
* **Máy trạm quản trị:** Windows 10

## 3. Cách dựng môi trường
Mô hình mạng được xây dựng bao gồm 3 vùng cơ bản: WAN (Internet), LAN (Nội bộ) và DMZ (Vùng phi quân sự).

* **Firewall pfSense (3 Card mạng):**
  * `WAN` (Adapter 1 - Bridged/NAT): Nhận IP DHCP từ mạng ngoài để ra Internet.
  * `LAN` (Adapter 2 - Host-only): Đặt IP tĩnh `10.0.0.1/8` đóng vai trò là Gateway cho toàn bộ máy trạm nội bộ.
  * `DMZ` (Adapter 3 - VMnet/Internal): Đặt IP tĩnh `172.16.0.1/16` dành riêng cho các máy chủ public (Web/Mail).
* **Máy Domain Controller (Windows Server):** 
  * Gắn card mạng LAN. Đặt IP tĩnh `10.0.0.2`, Subnet Mask `255.0.0.0`, Gateway `10.0.0.1`, DNS `10.0.0.2` (có cấu hình Forwarders ra `8.8.8.8`).
  * Cài đặt role Active Directory Domain Services (AD DS) và lên Domain `vietnam.local`.
* **Máy LAN-Test (Ubuntu Server):** 
  * Gắn card mạng LAN. Đặt IP tĩnh `10.0.0.3/8`, Gateway `10.0.0.1` để kiểm tra các chính sách chặn mạng.
* **Máy DMZ-Web (Windows Server):**
  * Gắn card mạng DMZ. Đặt IP tĩnh `172.16.0.2/16`, Gateway `172.16.0.1`, cài đặt role IIS (Web Server).

## 4. Các tình huống đã thực hiện & Kết quả
| Tình huống / Bài test | Mục tiêu | Kết quả |
| :--- | :--- | :---: |
| **Cấu hình nền tảng** | Cấu hình Outbound NAT (Hybrid), thiết lập Rule nền tảng (Pass LAN to Any) cho phép mạng nội bộ ra Internet. | **PASS** |
| **Tình huống 1** | Chặn ICMP (Ping) từ LAN ra ngoài nhưng vẫn cho phép phân giải tên miền (DNS) và lướt Web (HTTP/HTTPS). | **NO PASS** |
| **Tình huống 2** | Chỉ cấp quyền cho một Host cụ thể (Domain Controller - `10.0.0.2`) ra Internet, chặn toàn bộ các máy khác trong LAN (LAN-Test - `10.0.0.3`). | **NO PASS** |


## 5. Các lỗi gặp phải và Cách khắc phục
Trong quá trình thực hành, em đã gặp phải và tự xử lý các sự cố sau:

* **Lỗi 1: Máy thật không ping được máy ảo hoặc Gateway bị sai lệch đường đi (General Failure / Destination host unreachable).**
  * *Nguyên nhân:* Nhầm lẫn đặt IP Default Gateway cho card mạng ảo VMnet/Host-only trên máy thật.
  * *Khắc phục:* Vào `ncpa.cpl` trên máy thật, để trống hoàn toàn mục Default Gateway của card mạng quản trị, chỉ để lại IP `10.0.0.100`.

* **Lỗi 2: Không truy cập được giao diện WebGUI của pfSense (Quay vòng vòng / Time Out).**
  * *Khắc phục:* Vào Console pfSense dùng lệnh `16` (Restart PHP-FPM) hoặc `11` (Restart webConfigurator), đồng thời tắt tạm Windows Defender Firewall trên máy dùng để truy cập web.

* **Lỗi 3: Nâng cấp Domain Controller báo lỗi "Role change is in progress or this computer needs to be restarted".**
  * *Nguyên nhân:* Các service của Windows Server chưa cập nhật xong tiến trình cài đặt gói AD DS.
  * *Khắc phục:* Bấm Cancel, khởi động lại (Restart) máy ảo Windows Server và tiến hành Promote lại từ đầu.

* **Lỗi 4: Nâng cấp Domain Controller báo lỗi mật khẩu Administrator không đáp ứng độ phức tạp.**
  * *Nguyên nhân:* Tài khoản Administrator mặc định bị trống hoặc đặt pass quá yếu.
  * *Khắc phục:* Vào `Computer Management` -> `Local Users and Groups`, thiết lập lại mật khẩu cho Administrator đủ chuẩn (chữ hoa, chữ thường, số, ký tự đặc biệt, VD: `Admin@123456`).

* **Lỗi 5: Lệnh nslookup và curl trên máy Server báo "DNS request timed out" (kẹt ở giao thức IPv6 `::1`).**
  * *Nguyên nhân:* Cấu hình Preferred DNS trỏ sai hoặc chưa thông đường định tuyến cổng WAN trên pfSense.
  * *Khắc phục:* Hoàn thành Setup Wizard trên pfSense để có NAT
