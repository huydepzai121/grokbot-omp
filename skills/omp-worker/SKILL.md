---
name: omp-worker
description: Giao việc rẻ cho oh-my-pi (omp) chạy headless trên box: xử lý file/data, viết script + test, nháp tiếng Việt, batch song song. Không dùng cho việc cần browser hoặc gửi/ghi lên tài khoản thật.
---
# omp-worker: Grok Bot điều phối, omp thực thi

## Môi trường
- `omp` (oh-my-pi) cài bằng bun, nằm ở `~/.bun/bin/omp`.
- Provider chính: `viber` (https://bedrock.viber.vn, anthropic-messages, key qua env `VIBER_API_KEY`, không in ra). 
- Model mặc định và duy nhất dùng: `viber/deepseek-v4.1-flash-1017` (env `OMP_MODEL` để đổi nếu thật cần).

## Các bước
1. Mỗi phần việc một thư mục: `mkdir -p /tmp/work/<id>`, chép file đầu vào.
2. Viết prompt: mục tiêu, file vào/ra, tiêu chí đạt, "Chỉ làm trong thư mục này; không gửi/ghi/xoá gì lên dịch vụ ngoài; không bịa số liệu".
3. Chạy: `/workspace/omp-orchestrator/run-omp.sh /tmp/work/<id> prompt.txt`
   (bên trong: `omp -p --mode json --model ... --no-lsp --cwd <dir> --session-dir <dir>/.omp-session "<prompt>"`)
   Việc dài: chạy nền; nhiều phần: song song, mỗi phần một thư mục.
4. Đọc `meta.json` (exit), `final.txt`, `run.jsonl` (tìm `"stopReason":"error"` / `errorMessage`), và file đầu ra.
5. Tự kiểm tra lại số liệu/test. Sai thì nối phiên: `cd <dir> && omp -p --mode json -c --session-dir .omp-session "sửa ..."`.
6. Gom kết quả; mọi thứ gửi ra ngoài vẫn qua bước duyệt/draft của Grok Bot.

## Lưu ý
- omp không có sandbox workspace-write như dsh: giới hạn bằng prompt và `--tools=read,write,edit,bash` nếu cần.
- Lỗi `403 Insufficient account balance` = proxy hết tiền; nạp tiền hoặc đổi provider trong models.yml.
