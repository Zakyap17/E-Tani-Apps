import { GoogleGenerativeAI } from "@google/generative-ai";
import dotenv from "dotenv";

dotenv.config();

const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY || "");

const SYSTEM_INSTRUCTION = `Anda adalah Tani-AI, asisten pertanian cerdas dari E-Tani.
Tugas Anda membantu Juragan (petani) dengan solusi praktis dan cepat.

Aturan:
1. Sapa dengan sebutan "Juragan".
2. JANGAN gunakan format Markdown seperti bintang (**). Gunakan teks biasa saja.
3. Berikan jawaban yang singkat, padat, dan jelas.
4. Jika ada foto, langsung berikan diagnosa dan saran pengobatan.
5. KONSISTENSI WAJIB: Selalu baca riwayat percakapan sebelumnya secara cermat. Jika Anda sudah memberikan diagnosa atau analisa di pesan sebelumnya, gunakan diagnosa tersebut sebagai landasan jawaban berikutnya. JANGAN pernah memberikan jawaban yang bertentangan dengan diagnosa yang sudah Anda berikan sendiri.
6. Saat menjawab pertanyaan lanjutan seperti "solusinya apa?", "terus gimana?", atau "kenapa bisa begitu?", SELALU merujuk pada diagnosa/analisa sebelumnya dalam percakapan ini, bukan hanya pada kondisi cuaca saat ini.
7. Data cuaca real-time hanyalah konteks pendukung. Cuaca TIDAK boleh menjadi dasar jawaban jika sudah ada diagnosa spesifik sebelumnya.

Keahlian: Agronomi, Hama, dan Penyakit Tanaman.`;

// chatHistory: array of { role: "user"|"model", text: string }
export async function askTaniAI(prompt, imageBuffer = null, mimeType = null, weatherContext = "", chatHistory = []) {
  try {
    if (!process.env.GEMINI_API_KEY) {
      return "Waduh Juragan, sepertinya API Key Gemini belum dipasang di server. Mohon hubungi Team Developer.";
    }

    const model = genAI.getGenerativeModel({
      model: "gemini-2.0-flash",
      systemInstruction: SYSTEM_INSTRUCTION,
      generationConfig: {
        maxOutputTokens: 1000,
        temperature: 0.7,
      },
    });

    // Konversi riwayat percakapan ke format Gemini
    const geminiHistory = chatHistory.map(h => ({
      role: h.role === "model" ? "model" : "user",
      parts: [{ text: h.text }],
    }));

    // Tambahkan konteks cuaca hanya pada pesan pertama agar tidak mengganggu konsistensi diagnosa
    let currentPrompt = prompt;
    if (weatherContext && geminiHistory.length === 0) {
      currentPrompt = `Konteks Cuaca Saat Ini: ${weatherContext}\n\nPertanyaan Juragan: ${prompt}`;
    }

    const parts = [{ text: currentPrompt }];
    if (imageBuffer && mimeType) {
      parts.push({
        inlineData: {
          mimeType: mimeType,
          data: imageBuffer.toString("base64"),
        },
      });
    }

    // Gunakan startChat agar AI membaca seluruh riwayat percakapan
    const chat = model.startChat({ history: geminiHistory });
    const result = await chat.sendMessage(parts);
    return result.response.text();
  } catch (error) {
    const msg = error.message || "";
    console.error("[Tani-AI Error]", msg);

    if (msg.includes("429") || msg.toLowerCase().includes("quota") || msg.toLowerCase().includes("resource exhausted")) {
      return "Mohon maaf Juragan, Tani-AI sedang menerima banyak pertanyaan saat ini. Mohon tunggu sekitar 30-60 detik ya sebelum bertanya kembali. Terima kasih atas kesabarannya!";
    }

    if (msg.includes("403") || msg.toLowerCase().includes("permission denied") || msg.toLowerCase().includes("api key")) {
      console.error("[Tani-AI] API Key tidak valid atau tidak punya akses ke model ini.");
      return "Waduh Juragan, sepertinya ada masalah konfigurasi di server kami. Mohon hubungi Team Developer.";
    }

    if (msg.includes("404") || msg.toLowerCase().includes("not found")) {
      console.error("[Tani-AI] Model tidak ditemukan. Cek nama model di aiService.js.");
      return "Waduh Juragan, Tani-AI sedang dalam pemeliharaan. Mohon coba lagi dalam beberapa saat.";
    }

    return "Waduh Juragan, Tani-AI sedang tidak bisa menjawab saat ini. Coba kirim ulang pertanyaannya ya!";
  }
}

// FUNGSI INI SUDAH DIGANTIKAN OLEH LOGIKA MANUAL DI SERVICE.JS UNTUK STABILITAS
export async function generateDailyActivities(weatherContext, location = "Default") {
  return [];
}
