# grokbot-omp-orchestrator-vn

Grok Bot điều phối, **oh-my-pi (`omp`)** làm worker rẻ chạy headless trên box: mỗi việc một thư mục, trả về file kết quả + log JSON.

## Cài đặt
1. Cài bun và omp:
   ```sh
   curl -fsSL https://bun.sh/install | bash
   bun install -g @oh-my-pi/pi-coding-agent
   export PATH="$HOME/.bun/bin:$PATH"   # thêm vào ~/.bashrc
   omp --version
   ```
   bun có thể báo chặn postinstall (`bun pm -g untrusted`: onnxruntime-node, protobufjs). omp chạy headless bình thường mà không cần trust.
2. Cấu hình model: `mkdir -p ~/.omp/agent && cp config/models.yml.example ~/.omp/agent/models.yml` (nếu đã có file thì gộp phần `viber` vào), rồi `export VIBER_API_KEY=...`. Không commit key.
3. Copy `skills/omp-worker/SKILL.md` vào nơi Grok Bot đọc skill.

## Chạy
```sh
scripts/run-omp.sh [--model provider/model] <thu-muc> <file-prompt | "prompt">
```
Mặc định `viber/deepseek-v4.1-flash-1017` (đổi bằng `OMP_MODEL`). Kết quả trong thư mục: `run.jsonl` (sự kiện), `final.txt` (trả lời cuối), `run.err`, `meta.json` (exit, thời gian). Exit 0 = xong.

## Benchmark
Chạy thử 21/10/2026 với `viber/deepseek-v4.1-flash-1017` (làm sạch CSV đơn hàng → doanh thu theo khách/tháng): **exit 0, 51 giây**, số liệu khớp hoàn toàn với đối chiếu độc lập.

## Lưu ý
- omp không tự giới hạn việc ghi file trong thư mục: giới hạn phạm vi bằng prompt và `--tools`.
- Mọi việc gửi/ghi ra ngoài (Gmail, Lark, Zalo, Drive...) vẫn do Grok Bot làm qua bước duyệt.

Giấy phép: MIT, xem LICENSE.
