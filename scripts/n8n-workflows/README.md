# 🤖 paniund n8n Workflows

This directory contains pre-configured, exportable n8n workflows for the **paniund** intelligent career workspace.

---

## 📁 Included Workflows

| File | Purpose | Trigger | AI Engine |
| :--- | :--- | :--- | :--- |
| **`email-status-updater.json`** | Ingests recruiter emails, classifies status (interview/rejected/applied), and moves cards on the paniund CRM board automatically. | Email / Manual Test | DeepSeek Chat (`deepseek-chat`) |
| **`daily-job-radar.json`** | Periodically scans tech job feeds, evaluates candidate skill alignment with AI, and sends top picks to Telegram. | Schedule (Daily 8:00 AM) | DeepSeek Chat (`deepseek-chat`) |

---

## 🚀 How to Import Workflows into n8n

1. Start your local n8n instance:
   ```bash
   npm run n8n:start
   ```
2. Open your browser at **[http://localhost:5678](http://localhost:5678)**.
3. In n8n, click on **Workflows** in the left sidebar, then click **Add workflow** (or press `Ctrl + O`).
4. Click the three dots `...` in the top right corner of the canvas and select **"Import from File..."**.
5. Select `scripts/n8n-workflows/email-status-updater.json`.
6. Click **Save** (`Ctrl + S`).

---

## ⚙️ Environment Variables Required

Make sure your `.env.n8n` file contains:

```env
# Next.js Application URL (inside Docker, host.docker.internal points to your host machine)
PANIUND_API_URL=http://host.docker.internal:3000

# Your user API token generated from /api/user/token (starts with pnd_...)
PANIUND_API_TOKEN=pnd_your_token_here

# DeepSeek API Key (used by the AI classification node)
DEEPSEEK_API_KEY=sk-your_deepseek_key_here

# Telegram Bot Credentials (for daily-job-radar.json)
TELEGRAM_BOT_TOKEN=123456:ABC-DEF1234ghIkl-zyx57W2v1u123ew11
TELEGRAM_CHAT_ID=your_numeric_chat_id
```

### 📱 Getting Free Telegram Bot Credentials (1 Minute)
1. Open Telegram and search for `@BotFather`.
2. Send `/newbot`, give it a name (e.g. `MyJobRadarBot`), and a username (e.g. `my_job_radar_bot`).
3. Copy the HTTP API token provided into `TELEGRAM_BOT_TOKEN`.
4. Open a chat with your new bot and click **Start**.
5. To find your numeric Chat ID, message `@userinfobot` on Telegram and copy your `Id` into `TELEGRAM_CHAT_ID`.

---

## 🧪 Testing the Workflow

1. In the imported workflow canvas, click **"Test workflow"** at the bottom.
2. The **"Mock Email Sample"** node will feed a simulated recruiter email into DeepSeek.
3. DeepSeek extracts:
   ```json
   {
     "isJobEmail": true,
     "company": "Stripe",
     "jobTitle": "Fullstack Engineer",
     "status": "interview",
     "interviewDate": "2026-12-05T14:00:00.000Z",
     "summary": "Invited for 45-minute technical screen."
   }
   ```
4. The HTTP Request node sends this to `POST /api/webhooks/n8n`, and your paniund dashboard automatically moves the Stripe application to the `Interview` column!

---

## 📬 Connecting Real Inboxes (Gmail / Outlook / IMAP)

To run this 24/7 on your actual inbox:
1. In n8n, click `+` and search for **Email Read (IMAP)** or **Gmail**.
2. Connect your email account using an App Password (or OAuth).
3. Set the filter to only fetch emails matching keywords like `interview`, `application`, `careers`, or `offer`.
4. Connect the output of the Email node to the **DeepSeek Email Classifier** node.
5. Toggle the workflow to **Active**.
