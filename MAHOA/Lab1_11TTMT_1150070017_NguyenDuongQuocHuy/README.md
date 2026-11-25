# LAB 1 – MÃ HÓA ĐỐI XỨNG CỔ ĐIỂN
**Java Swing (NetBeans GUI Builder) – Maven – Microsoft SQL Server**

---

## 1. Thông tin sinh viên
- **Họ và tên:** Nguyễn Dương Quốc Huy
- **MSSV:** 1150070017
- **Lớp:** 11_ĐH_TTMT
- **Tên bài thực hành:** LAB 1 – Mã hóa đối xứng cổ điển (`LAB1_MaHoaCoDien`)
- **Ngày thực hành:** 10/11/2026

---

## 2. Phiên bản môi trường thực hành
| Thành phần | Phiên bản / Cấu hình sử dụng |
| :--- | :--- |
| **Hệ điều hành** | Windows 11 64-bit (`amd64`) |
| **Ngôn ngữ & JDK** | Java – OpenJDK Temurin `21.0.13` LTS (64-bit), biên dịch chuẩn Maven Release `17` |
| **IDE lập trình** | Apache NetBeans IDE `31` (thiết kế giao diện bằng NetBeans GUI Builder) |
| **Quản lý dự án (Build Tool)** | Apache Maven (`GroupId: vn.edu.lab`, `ArtifactId: LAB1_MaHoaCoDien`, `Version: 1.0-SNAPSHOT`, `Package: week_01`) |
| **Thư viện kết nối CSDL** | Microsoft JDBC Driver (`com.microsoft.sqlserver:mssql-jdbc:12.8.1.jre11`) |
| **Hệ quản trị CSDL** | Microsoft SQL Server 2025 Express (`17.0.1000`) – Instance: `SQLEXPRESS` |
| **Công cụ quản lý SQL** | SQL Server Management Studio (`SSMS 22.11.0`) |
| **Quản lý mã nguồn** | Git `2.54.0.windows.1` & GitHub |

---

## 3. Cách dựng môi trường và chạy chương trình

### Bước 1: Chuẩn bị JDK và Apache NetBeans
1. Cài đặt **OpenJDK 21 LTS** và kiểm tra trên Command Prompt bằng lệnh `java -version`.
2. Cài đặt **Apache NetBeans IDE 31**.

### Bước 2: Cấu hình Microsoft SQL Server Express & SSMS
1. Mở **SQL Server Configuration Manager** (`SQLServerManager17.msc`):
   - Vào **SQL Server Network Configuration** $\rightarrow$ **Protocols for SQLEXPRESS** $\rightarrow$ Bật (**Enable**) giao thức **TCP/IP**.
   - Nhấp đúp vào **TCP/IP** $\rightarrow$ tab **IP Addresses** $\rightarrow$ kéo xuống mục **IPAll**: xóa trống ô `TCP Dynamic Ports` và điền `14333` vào ô `TCP Port`.
2. Mở **SSMS**, kết nối vào `localhost\SQLEXPRESS` bằng **Windows Authentication**:
   - Nhấp phải vào Server $\rightarrow$ **Properties** $\rightarrow$ **Security** $\rightarrow$ chọn **SQL Server and Windows Authentication mode (Mixed Mode)**.
   - Khởi động lại (**Restart**) dịch vụ `SQL Server (SQLEXPRESS)`.
3. Chạy lần lượt các script SQL trong thư mục SQL của bài lab:
   - `01_Tao_CSDL.sql`: Tạo database `LAB1_MaHoaCoDien` và bảng `dbo.history`.
   - `02_Tao_Login_MAU.sql`: Tạo tài khoản đăng nhập `lab1_user`, ánh xạ user vào `LAB1_MaHoaCoDien` và cấp quyền `SELECT, INSERT, DELETE` trên bảng `dbo.history`.
4. Kiểm tra kết nối trên SSMS với `Server name = 127.0.0.1,14333`, `Authentication = SQL Server Authentication`, `Login = lab1_user` (tích chọn *Trust server certificate*).

### Bước 3: Biên dịch và chạy Project Maven trên NetBeans
1. Mở project `LAB1_MaHoaCoDien` trong Apache NetBeans.
2. Nhấp phải vào project $\rightarrow$ chọn **Clean and Build** (`Shift + F11`) để Maven tải thư viện `mssql-jdbc-12.8.1.jre11.jar` và biên dịch mã nguồn đạt trạng thái `BUILD SUCCESS`.
3. Chạy từng form bằng **Run File** (`Shift + F6`) hoặc chạy toàn bộ chương trình bằng **Run Project** (`F6`).

---

## 4. Các tình huống đã thực hiện và Kết quả kiểm thử (PASS/FAIL)

| STT | Hạng mục / Tình huống kiểm thử | Dữ liệu đầu vào (Plaintext / Cấu hình) | Khóa (Key) | Kết quả thực tế thu được | Đánh giá |
| :---: | :--- | :--- | :--- | :--- | :---: |
| 1 | **Bài 1.1 – Mật mã Caesar** (`frm_Caesar`) | `HELLO` | `3` | Ciphertext: `KHOOR` (Giải mã ngược về `HELLO`) | **PASS** |
| 2 | **Bài 1.2 – Mật mã Vigenère** (`frm_Vigenere`) | `HELLO` | `KEY` | Ciphertext: `RIJVS` (Giải mã ngược về `HELLO`) | **PASS** |
| 3 | **Bài 1.3 – Mật mã Rail Fence** (`frm_RailFence`) | `HELLO WORLD` | `3` | Ciphertext: `HOREL OLLWD` (Giải mã ngược về `HELLO WORLD`) | **PASS** |
| 4 | **Bài 1.4 – Mật mã Playfair** (`frm_Playfair`) | `HELLOWORLD` | `KEYWORD` | Tạo ma trận 5×5 (I/J chung ô); Ciphertext: `GYIZSCOKCFBU` | **PASS** |
| 5 | **Bài 1.5 – Mật mã Transposition** (`frm_Transposition`) | `BAOMAT` | `2,3,1` | Ciphertext: `AAOTBM` (Giải mã ngược về `BAOMAT`) | **PASS** |
| 6 | **Bài 1.6 – Mật mã Autokey** (`frm_Autokey`) | `HELLO` | `KEY` | Ciphertext: `RIJSS` (Giải mã ngược về `HELLO`) | **PASS** |
| 7 | **Đọc / Ghi tệp văn bản `.txt`** (`FileTextIO`) | Lưu & mở file `.txt` (UTF-8) trên các form | - | Lưu bản mã ra file `.txt` và mở lại hiển thị đúng nội dung | **PASS** |
| 8 | **Kiểm soát nhập khóa không hợp lệ** | Nhập khóa sai định dạng (`abc`, `K3Y`, `1`, `1,1,2`) | Khóa sai | Hiển thị hộp thoại `JOptionPane` cảnh báo lỗi, chương trình không bị dừng đột ngột | **PASS** |
| 9 | **Chương trình tổng hợp 6 thuật toán** (`frm_TongHop`) | Chọn lần lượt 6 thuật toán trên `JComboBox` | Tự động gợi ý khóa mẫu | Mã hóa / giải mã chính xác cả 6 thuật toán trên một giao diện | **PASS** |
| 10 | **Kết nối SQL Server qua JDBC** (`frm_KetNoiSQL`) | `Server: 127.0.0.1`, `Port: 14333`, `DB: LAB1_MaHoaCoDien`, `User: lab1_user` | Mật khẩu tài khoản Lab | Báo: `Kết nối thành công: Microsoft SQL Server 17.0.1000 - database LAB1_MaHoaCoDien` | **PASS** |
| 11 | **Ghi và đọc lịch sử thao tác** (`frm_LichSu` & SSMS) | Thực hiện `ENCRYPT` đủ 6 thuật toán trên `frm_TongHop` | - | Tự động lưu 6 bản ghi vào `dbo.history`, tải lên `JTable` (`frm_LichSu`) khớp 100% với truy vấn `SELECT` trong SSMS | **PASS** |

---

## 5. Các lỗi gặp phải và Cách khắc phục

1. **Lỗi phiên bản JDK mặc định trên máy thấp hơn yêu cầu (`openjdk 11.0.31`):**
   - **Nguyên nhân:** Máy tính cài sẵn JDK 11 trong biến môi trường, không đáp ứng cấu hình `<maven.compiler.release>17</maven.compiler.release>` trong `pom.xml`.
   - **Cách khắc phục:** Cài đặt bản **OpenJDK Temurin 21.0.13 LTS** và cập nhật lại biến môi trường `PATH` để hệ thống và Maven nhận JDK 21.

2. **Lỗi hiển thị nhãn trạng thái (`lbl_status`) bị cắt chữ thành dấu `...` trên Form:**
   - **Nguyên nhân:** Khi kéo thả `JLabel` làm dòng trạng thái dưới cùng trên `frm_Caesar`, chiều rộng mặc định của nhãn quá hẹp nên không hiển thị hết chuỗi thông báo.
   - **Cách khắc phục:** Mở tab `Design` trên NetBeans GUI Builder, kéo rộng kích thước chiều ngang của `lbl_status` bằng với chiều ngang ô `txt_ciphertext` (`570px`).

3. **Lỗi đăng nhập SQL Server `Login failed for user 'lab1_user' (Microsoft SQL Server, Error: 18456)`:**
   - **Nguyên nhân:** SQL Server Express mặc định chỉ bật chế độ *Windows Authentication mode* hoặc sau khi chuyển sang *Mixed Mode* và chạy script tạo tài khoản `lab1_user` nhưng chưa khởi động lại dịch vụ SQL Server.
   - **Cách khắc phục:** Bật chế độ **SQL Server and Windows Authentication mode (Mixed Mode)**, chạy đầy đủ script tạo login `lab1_user` kèm cấp quyền trên bảng `dbo.history`, sau đó vào **SQL Server Configuration Manager** chọn **Restart** dịch vụ `SQL Server (SQLEXPRESS)`.

4. **Vấn đề bảo mật thông tin xác thực khi đẩy code lên GitHub:**
   - **Nguyên nhân:** Nguy cơ lộ mật khẩu SQL Server trong mã nguồn Java hoặc trong các tệp script `.sql`.
   - **Cách khắc phục:** Lớp `DbConfig.java` nhận mật khẩu từ `JPasswordField` dưới dạng mảng `char[]` và chỉ lưu tạm trên RAM trong phiên chạy (không gán cứng trong code). Các tệp `.sql` khi đóng gói đẩy lên GitHub được thay thế mật khẩu thật bằng chuỗi giữ chỗ `<MAT_KHAU_LAB>` và cấu hình `.gitignore` để loại bỏ thư mục biên dịch `target/` cùng các file `.class`.
