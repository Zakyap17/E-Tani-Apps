import Groq from "groq-sdk";
import dotenv from "dotenv";

dotenv.config();

const groq = new Groq({ apiKey: process.env.GROQ_API_KEY });

const SYSTEM_INSTRUCTION = `Anda adalah Tani-AI, asisten tanaman cerdas dari E-Tani.
Tugas Anda membantu siapa saja yang merawat tanaman — baik petani, pecinta tanaman hias, maupun pemula sekalipun — dengan solusi praktis dan cepat.

Aturan:
1. Sapa dengan sebutan "Juragan".
2. JANGAN gunakan format Markdown seperti bintang (**). Gunakan teks biasa saja.
3. Berikan jawaban yang singkat, padat, dan jelas.
4. Jika ada foto, langsung berikan diagnosa dan saran pengobatan.
5. KONSISTENSI WAJIB: Selalu baca riwayat percakapan sebelumnya secara cermat. Jika Anda sudah memberikan diagnosa atau analisa di pesan sebelumnya, gunakan diagnosa tersebut sebagai landasan jawaban berikutnya. JANGAN pernah memberikan jawaban yang bertentangan dengan diagnosa yang sudah Anda berikan sendiri.
6. Saat menjawab pertanyaan lanjutan seperti "solusinya apa?", "terus gimana?", atau "kenapa bisa begitu?", SELALU merujuk pada diagnosa/analisa sebelumnya dalam percakapan ini, bukan hanya pada kondisi cuaca saat ini.
7. Data cuaca real-time hanyalah konteks pendukung. Cuaca TIDAK boleh menjadi dasar jawaban jika sudah ada diagnosa spesifik sebelumnya.

Keahlian: Agronomi, Tanaman Hias, Hama, Penyakit Tanaman, dan Perawatan Tanaman Rumahan.`;

// chatHistory: array of { role: "user"|"model", text: string }
export async function askTaniAI(prompt, imageBuffer = null, mimeType = null, weatherContext = "", chatHistory = []) {
  try {
    if (!process.env.GROQ_API_KEY) {
      return "Waduh Juragan, sepertinya API Key belum dipasang di server. Mohon hubungi Team Developer.";
    }

    // Konversi history ke format OpenAI/Groq (role: "model" → "assistant")
    const groqHistory = chatHistory.map(h => ({
      role: h.role === "model" ? "assistant" : "user",
      content: h.text,
    }));

    // Tambahkan konteks cuaca hanya pada pesan pertama
    let currentPrompt = prompt;
    if (weatherContext && chatHistory.length === 0) {
      currentPrompt = `Konteks Cuaca Saat Ini: ${weatherContext}\n\nPertanyaan Juragan: ${prompt}`;
    }

    // Pilih model: vision untuk pesan dengan gambar, gemma2 untuk teks (1.500 RPM, kualitas lebih baik)
    const model = imageBuffer
      ? "meta-llama/llama-4-scout-17b-16e-instruct"
      : "gemma2-9b-it";

    // Format pesan user: array (teks + gambar) atau string biasa
    let userContent;
    if (imageBuffer && mimeType) {
      userContent = [
        { type: "text", text: currentPrompt },
        {
          type: "image_url",
          image_url: {
            url: `data:${mimeType};base64,${imageBuffer.toString("base64")}`,
          },
        },
      ];
    } else {
      userContent = currentPrompt;
    }

    const completion = await groq.chat.completions.create({
      model,
      messages: [
        { role: "system", content: SYSTEM_INSTRUCTION },
        ...groqHistory,
        { role: "user", content: userContent },
      ],
      max_tokens: 1000,
      temperature: 0.7,
    });

    return completion.choices[0].message.content;
  } catch (error) {
    const msg = error.message || "";
    console.error("[Tani-AI Error]", msg);

    if (error.status === 429 || msg.toLowerCase().includes("rate limit")) {
      return "Mohon maaf Juragan, Tani-AI sedang menerima banyak pertanyaan saat ini. Mohon tunggu sekitar 30-60 detik ya sebelum bertanya kembali. Terima kasih atas kesabarannya!";
    }

    if (error.status === 401 || msg.toLowerCase().includes("api key") || msg.toLowerCase().includes("authentication")) {
      console.error("[Tani-AI] API Key Groq tidak valid.");
      return "Waduh Juragan, sepertinya ada masalah konfigurasi di server kami. Mohon hubungi Team Developer.";
    }

    return "Waduh Juragan, Tani-AI sedang tidak bisa menjawab saat ini. Coba kirim ulang pertanyaannya ya!";
  }
}

export async function generateDailyActivities(weatherContext, location = "Default") {
  return [];
}
