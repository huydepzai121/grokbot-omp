# grokbot-omp-orchestrator-vn

Grok Bot điều phối, **oh-my-pi (`omp`)** làm worker rẻ chạy headless trên box: mỗi việc một thư mục, trả về file kết quả + log JSON.
Dựa trên [diginno-net/grokbot-dsh-orchestrator-vn](https://github.com/diginno-net/grokbot-dsh-orchestrator-vn) (bản gốc dùng `dsh`), chuyển sang `omp`.

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

## Benchmark (examples/don-hang)
```sh
mkdir -p /tmp/work/don-hang && cp examples/don-hang/don_hang_tho.csv /tmp/work/don-hang/
scripts/run-omp.sh /tmp/work/don-hang examples/don-hang/prompt.txt
```
Kết quả 21/10/2026 với `viber/deepseek-v4.1-flash-1017`: **exit 0, 51 giây**, tạo `clean.py`, `result.csv`, `summary.md`. Đối chiếu bằng script độc lập: 42 dòng gốc, 2 trùng, 1 thiếu số lượng, tổng doanh thu 56.280.000 đ, top 3 Minh Phát / Hoàng Long / Trần Thị Bích, tháng cao nhất 2026-08 (26.550.000 đ) — **khớp hoàn toàn**.

## Lưu ý
- omp không có sandbox `workspace-write` như dsh: giới hạn phạm vi bằng prompt và `--tools`.
- Mọi việc gửi/ghi ra ngoài (Gmail, Lark, Zalo, Drive...) vẫn do Grok Bot làm qua bước duyệt.

Giấy phép: xem LICENSE (theo repo gốc).
