import { GoogleGenerativeAI } from "@google/generative-ai";
import dotenv from "dotenv";

dotenv.config();

const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY || "");

const SYSTEM_PROMPT = `
Anda adalah Tani-AI, seorang Konsultan Senior Ahli Pertanian (setingkat Magister/S2 Pertanian) dari platform E-Tani.
Karakter Anda adalah profesional, cerdas, berwawasan luas, namun tetap rendah hati dan komunikatif.

Aturan Komunikasi & Analisis:
1. Sapa selalu pengguna dengan sebutan "Juragan".
2. PRIORITAS KECEPATAN: Berikan jawaban yang langsung ke inti masalah (To-the-point). Hindari penjelasan basa-basi yang terlalu panjang.
3. Struktur Jawaban: Berikan DIAGNOSA ringkas diikuti dengan SOLUSI PRAKTIS (langkah 1, 2, 3).
4. Rekomendasi Strategic: Cukup 1-2 poin penting untuk pencegahan jangka panjang.
5. Konteks Cuaca: Gunakan hanya jika sangat krusial bagi tindakan petani saat ini.
6. JANGAN gunakan format Markdown seperti bintang (**). Gunakan teks biasa saja.
7. Jika masalah sangat kritis, arahkan ke tombol "Tanya Ahli Pertanian".

Keahlian: Agronomi, Fitopatologi, Entomologi, Ilmu Tanah, dan Agrometeorologi.
`;

export async function askTaniAI(prompt, imageBuffer = null, mimeType = null, weatherContext = "") {
  try {
    if (!process.env.GEMINI_API_KEY) {
      return "Waduh Juragan, sepertinya API Key Gemini belum dipasang di server. Mohon hubungi Team Developer.";
    }

    const model = genAI.getGenerativeModel({ 
      model: "gemini-flash-latest", 
      generationConfig: {
        maxOutputTokens: 500, 
        temperature: 0.7,
      },
    });

    let fullPrompt = SYSTEM_PROMPT;
    if (weatherContext) {
      fullPrompt += "\n\nKonteks Cuaca Saat Ini:\n" + weatherContext;
    }
    fullPrompt += "\n\nPesan Juragan: " + prompt;

    let contents = [{ role: "user", parts: [{ text: fullPrompt }] }];

    if (imageBuffer && mimeType) {
      contents[0].parts.push({
        inlineData: {
          mimeType: mimeType,
          data: imageBuffer.toString("base64"),
        },
      });
    }

    const result = await model.generateContent({ contents });
    const response = await result.response;
    return response.text();
  } catch (error) {
    console.error("AI Error:", error);
    return `Waduh Juragan, ada error teknis dari Google: ${error.message}. Coba kabari Team Developer ya!`;
  }
}
