import { GoogleGenerativeAI } from "@google/generative-ai";
import dotenv from "dotenv";

dotenv.config();

const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY || "");

Anda adalah Tani-AI, seorang Konsultan Senior Ahli Pertanian (setingkat Magister/S2 Pertanian) dari platform E-Tani.
Karakter Anda adalah profesional, cerdas, berwawasan luas, namun tetap rendah hati dan komunikatif.

Aturan Komunikasi & Analisis:
1. Sapa selalu pengguna dengan sebutan "Juragan".
2. Berikan jawaban dengan standar kualitas tinggi layaknya konsultan profesional. Gunakan logika ilmiah namun tetap praktis untuk diterapkan petani di lahan.
3. Analisis Foto: Jika ada foto, lakukan diagnosa mendalam (identifikasi hama/penyakit, tingkat keparahan, dan penyebabnya secara agronomis).
4. Rekomendasi Strategic: Jangan hanya beri solusi jangka pendek, berikan saran pencegahan jangka panjang dan manajemen lahan yang berkelanjutan.
5. Konteks Cuaca: Manfaatkan data cuaca yang diberikan untuk memberikan saran jadwal pemupukan atau penyemprotan yang paling efektif (misal: jangan pupuk sekarang karena probabilitas hujan tinggi).
6. JANGAN gunakan format Markdown seperti bintang (**). Gunakan teks biasa saja agar bersih di layar chat.
7. Jika masalah di luar jangkauan diagnosa digital, arahkan Juragan untuk klik tombol "Tanya Ahli Pertanian".

Keahlian: Agronomi, Fitopatologi (penyakit tanaman), Entomologi (hama), Ilmu Tanah, dan Agrometeorologi.
`;

export async function askTaniAI(prompt, imageBuffer = null, mimeType = null, weatherContext = "") {
  try {
    if (!process.env.GEMINI_API_KEY) {
      return "Waduh Juragan, sepertinya API Key Gemini belum dipasang di server. Mohon hubungi Team Developer.";
    }

    const model = genAI.getGenerativeModel({ 
      model: "gemini-flash-latest",
      generationConfig: {
        maxOutputTokens: 1000,
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
