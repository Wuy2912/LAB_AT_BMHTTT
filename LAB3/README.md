Nguyễn Dương Quốc Huy
1150070017
Lab 3 – Nhận diện và ứng phó các mối đe dọa an toàn thông tin


## 1. Phiên bản môi trường thực thi
Windows 10 (phiên bản 64-bit)
VMware Workstation Pro
Các công cụ hỗ trợ: Microsoft Defender, Windows Event Viewer, Sysinternals Autoruns, Wireshark

## 2. Cách dựng môi trường
1. Khởi động máy ảo Windows trên phần mềm VMware Workstation Pro.
2. Thiết lập cấu hình mạng cho máy ảo (chế độ Host-only).
3. Chuẩn bị thư mục làm việc chính tại đường dẫn `C:\LAB3\`, bao gồm thư mục con `Evidence\` để lưu trữ các hình ảnh minh chứng và thư mục `Tools\` chứa các bộ công cụ bổ trợ (như Autoruns, Wireshark).
4. Cấp quyền quản trị viên (Administrator) cho cửa sổ PowerShell để thực thi các lệnh cấu hình bảo mật hệ thống.

## 3. Các tình huống đã thực hiện
* **Tình huống 1 (TH1):** Phân tích rủi ro, phân loại tình huống bảo mật (Asset, Vulnerability, Threat, Risk, Attack).
* **Tình huống 2 (TH2):** Kiểm tra cơ chế phát hiện mã độc của Microsoft Defender bằng chuỗi mẫu EICAR.
* **Tình huống 3 (TH3):** Mô phỏng tấn công mật khẩu, sinh log xác thực (Event IDs 4624, 4625, 4648) và phân tích nguy cơ Keylogging.
* **Tình huống 4 (TH4):** Nhận diện mã độc ẩn trú (Persistence) bằng công cụ Autoruns thông qua việc tạo và quét khóa Registry khởi động (`Run`).
* **Tình huống 5 (TH5):** Bắt và phân tích gói tin mạng bằng Wireshark, so sánh sự khác biệt giữa giao thức HTTP (cleartext) và HTTPS (đã mã hóa).
* **Tình huống 6 (TH6):** Phân tích cơ chế tấn công DoS/DDoS, Mail Bombing và kiểm tra trạng thái kết nối mạng, tài nguyên hệ thống.
* **Tình huống 7 (TH7):** Nghiên cứu các hình thức tấn công phi kỹ thuật (Social Engineering, Phishing, Spear Phishing) và biện pháp phòng ngừa.

## 4. Kết quả thực hiện
Lab 1,2,3,4 thực hiện ổn thỏa
Lab 5,6 tự giả lập
Lab 7 không ổn

## 5. Lỗi gặp phải và cách khắc phục
**Lỗi 1 (Lệnh `runas` báo lỗi *"Unable to acquire user password"* trong PowerShell):**
  * *Nguyên nhân:* Môi trường PowerShell chặn luồng nhập mật khẩu ẩn của công cụ `runas` truyền thống.
  * *Cách khắc phục:* Chuyển sang sử dụng cửa sổ Command Prompt (CMD) với quyền Admin để gõ tay trực tiếp, hoặc dùng câu lệnh PowerShell chuyên dụng kết hợp `ConvertTo-SecureString` và `PSCredential` để cấp quyền khởi chạy tiến trình.
**Lỗi 2 (Lệnh mạng `Get-NetTCPConnection -State Established` báo không tìm thấy đối tượng):**
  * *Nguyên nhân:* Tại thời điểm kiểm tra, máy ảo không có kết nối TCP nào đang ở trạng thái `Established` hoặc cú pháp kén phiên bản hệ điều hành.
  * *Cách khắc phục:* Thay thế bằng lệnh tổng quát `Get-NetTCPConnection` để liệt kê toàn bộ trạng thái cổng mạng kết nối mà không bị ràng buộc bộ lọc.
