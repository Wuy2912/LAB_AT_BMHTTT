# BÁO CÁO THỰC HÀNH - LAB 4: KHẢO SÁT MẠNG VÀ TÌM KIẾM LỖ HỔNG VỚI NMAP

## 1. Thông tin sinh viên
- **Họ và tên:** Nguyễn Dương Quốc Huy
- **MSSV:** 1150070017
- **Tên Lab:** LAB 4 - Network Discovery, Service Identification, and Vulnerability Assessment using Nmap
- **Môn học:** An toàn Hệ thống Thông tin

---

## 2. Thông tin môi trường (Environment Versions)
- **Nền tảng ảo hóa:** VMware Workstation Pro.
- **Máy tấn công (Attacker):** Kali Linux (chạy trên máy ảo).
- **Máy mục tiêu (Target):** Metasploitable 2 (hệ điều hành Linux 2.6.x chứa các dịch vụ có lỗ hổng).
- **Máy trạm (Host):** Windows (máy tính vật lý).
- **Công cụ sử dụng chính:** Nmap v7.99, Npcap, Trình duyệt Firefox, Python 3 (built-in http.server).

---

## 3. Cách dựng môi trường (Environment Setup)
1. **Thiết lập mạng ảo:** Đưa cả máy ảo Kali Linux và Metasploitable 2 về chung một card mạng **Host-Only** (VMnet1) để cô lập môi trường thực hành và đảm bảo các máy có thể ping thấy nhau.
2. **Cấu hình IP (Subnet `192.168.232.0/24`):**
   - **Windows Host (Máy thật):** `192.168.232.130`
   - **Kali Linux (Attacker):** `192.168.232.131`
   - **Metasploitable 2 (Target):** `192.168.232.132`
3. **Chuẩn bị công cụ:** Đã cài đặt hoàn thiện bộ Nmap/Zenmap/Npcap. Các câu lệnh được thực thi trực tiếp trên Terminal của Kali Linux.

---

## 4. Các tình huống đã thực hiện & Kết quả (Scenarios & Results)

| STT | Kỹ thuật quét / Tình huống thực hiện | Lệnh tiêu biểu | Kết quả |
| :--- | :--- | :--- | :---: |
| 1 | Host Discovery (Phát hiện máy chủ) | `sudo nmap -sn 192.168.232.0/24` | **PASS** |
| 2 | TCP Connect scan (Quét bắt tay 3 bước) | `nmap -sT 192.168.232.132` | **PASS** |
| 3 | SYN scan (Quét tàng hình - raw packet) | `sudo nmap -sS 192.168.232.132` | **PASS** |
| 4 | FIN / Xmas / NULL scan | `sudo nmap -sF/-sX/-sN 192.168.232.132` | **PASS** |
| 5 | ACK scan (Kiểm tra quy tắc tường lửa) | `sudo nmap -sA 192.168.232.132` | **PASS** |
| 6 | UDP scan (Giới hạn top 20 cổng) | `sudo nmap -sU --top-ports 20 192.168.232.132` | **PASS** |
| 7 | Version & OS Detection (Nhận diện OS/Dịch vụ) | `sudo nmap -sV -O 192.168.232.132` | **PASS** |
| 8 | Aggressive scan (Quét tổng hợp) | `sudo nmap -A 192.168.232.132` | **PASS** |
| 9 | NSE Scripts (Dò thông tin & lỗ hổng SMB) | `sudo nmap -p 445 --script smb-os-discovery...` | **PASS** |
| 10 | Xuất báo cáo (txt, xml, grepable) & HTML | `... -oN ket_qua.txt`, `xsltproc ...` | **PASS** |
| 11 | Chuyển file báo cáo từ Kali ra máy tính Host | Gửi qua Web Server Python / Zalo Web | **PASS** |

---

## 5. Lỗi gặp phải và Cách khắc phục (Troubleshooting)

Trong quá trình thực hành, một số lỗi thao tác dòng lệnh và mạng đã xảy ra. Dưới đây là nhật ký lỗi và cách xử lý:

1. **Lỗi:** `failed to determine route` (Không tìm thấy đường đi khi chạy FIN/Xmas/NULL scan).
   - **Nguyên nhân:** Gõ sai địa chỉ IP đích (gõ nhầm dải mạng `212` thành `192.168.212.132` thay vì dải `232`).
   - **Cách khắc phục:** Kiểm tra lại và gõ chính xác IP mục tiêu là `192.168.232.132`.

2. **Lỗi:** `unrecognized option '-0'` (Không nhận diện được tùy chọn khi quét OS).
   - **Nguyên nhân:** Gõ nhầm tham số `-O` (chữ O in hoa - OS detection) thành `-0` (số không). Nmap phân biệt chặt chẽ chữ hoa/thường/số.
   - **Cách khắc phục:** Sửa cú pháp thành `-O`. 

3. **Lỗi:** `failed to load external entity "ket_qua.xml"` (Khi dùng lệnh `xsltproc` tạo HTML).
   - **Nguyên nhân:** Do lệnh quét xuất file XML trước đó bị lỗi gõ nhầm tham số (Lỗi số 2) nên file `ket_qua.xml` chưa hề được tạo ra trên hệ thống.
   - **Cách khắc phục:** Chạy lại lệnh quét Nmap đúng cú pháp để tạo file XML (`sudo nmap -sV -O 192.168.232.132 -oX ket_qua.xml`) chờ chạy xong 100%, sau đó mới chạy lệnh `xsltproc`.

4. **Lỗi:** `No module named http.sever` (Khi tạo máy chủ tải file).
   - **Nguyên nhân:** Sai chính tả từ khóa module Python (gõ thiếu chữ 'r' thành `sever`).
   - **Cách khắc phục:** Gõ lại chính xác cú pháp: `python3 -m http.server 8080`.

5. **Lỗi:** Báo lỗi Google tìm kiếm hoặc `ERR_CONNECTION_TIMED_OUT` khi tải file ra máy thật.
   - **Nguyên nhân:** Copy nhầm các ký hiệu ngoặc của định dạng văn bản dán vào ô Google Search, hoặc tab Terminal chạy Web Server trên Kali đã bị tắt giữa chừng khiến cổng 8080 đóng lại.
   - **Cách khắc phục:** Luôn giữ Terminal chạy lệnh `http.server` ngầm không được tắt. Trên máy thật, gõ trực tiếp IP và Port `192.168.232.131:8080` lên thanh địa chỉ (Address Bar) của trình duyệt. 

6. **Lỗi:** Trống danh sách file khi mở cửa sổ chọn file tải lên Zalo Web trên Firefox (Kali).
   - **Nguyên nhân:** Cửa sổ duyệt file mặc định mở ở mục **Recent** (Gần đây) nên không hiển thị các file vừa xuất qua dòng lệnh.
   - **Cách khắc phục:** Chuyển hướng sang thư mục **Home** ở cột bên trái, các file báo cáo (txt, html, xml) được lưu mặc định tại đây.
