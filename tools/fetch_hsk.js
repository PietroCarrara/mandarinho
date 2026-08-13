const fs = require("fs");

const hsk = 5;
const pageSizes = {
  1: 150,
  2: 150,
  3: 300,
  4: 600,
  5: 1300,
};

(async () => {
  const json = await (
    await fetch("https://api.hskmock.com/mock/word/searchWords", {
      credentials: "include",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        level_ids: [hsk],
        initial: "",
        keyword: "",
        page_num: 1,
        page_size: pageSizes[hsk],
      }),
      method: "POST",
    })
  ).json();

  console.log({ json });
  const list = json.data.list;

  let out = `INSERT INTO dictionary_entries(hanzi_simplified, pinyin, pinyin_numeric, pinyin_ascii, hsk) VALUES`;
  let values = [];
  for (word of list) {
    values.push(
      `\n('${word.word}', '${word.pinyin_tone.replace(/ /g, "")}', '${word.pinyin_num.replace(/ /g, "")}', '${word.pinyin.replace(/ /g, "")}', ${hsk})`,
    );
  }
  out += values.join(",") + `;`;
  fs.writeFileSync(`hsk${hsk}.sql`, out);
})();
