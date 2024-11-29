import pyotp
import qrcode

# Bước 1: Tạo khóa bí mật
secret_key = pyotp.random_base32()
print(f"Secret Key: {secret_key}")

# Bước 2: Tạo URI để hiển thị trong Google Authenticator
issuer_name = "NHP"  # Tên ứng dụng
user_email = "nhpphi2002@gmail.com"  # Tài khoản người dùng
totp = pyotp.TOTP(secret_key)
uri = totp.provisioning_uri(name=user_email, issuer_name=issuer_name)

# Bước 3: Tạo mã QR để người dùng quét
qr = qrcode.make(uri)
qr.save("nhp_qr.png")
print("Mã QR đã được tạo. Người dùng có thể quét để thêm vào Google Authenticator.")
