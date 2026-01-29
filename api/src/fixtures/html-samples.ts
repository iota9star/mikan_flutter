// HTML fixtures for testing
// Load real HTML files downloaded from Mikan
import { readFileSync } from 'fs';
import { fileURLToPath } from 'url';
import { dirname, join } from 'path';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

function readHtmlFile(filename: string): string {
  try {
    return readFileSync(join(__dirname, filename), 'utf-8');
  } catch (error) {
    console.error(`Failed to read ${filename}:`, error);
    return '';
  }
}

// Real HTML from Mikan
export const indexHtml = readHtmlFile('index.html');
export const seasonHtml = readHtmlFile('season.html');
export const dayHtml = readHtmlFile('day.html');
export const searchHtml = readHtmlFile('search.html');
export const bangumiHtml = readHtmlFile('bangumi.html');
export const episodeHtml = readHtmlFile('episode.html');
export const listHtml = readHtmlFile('list.html');
export const myBangumiHtml = readHtmlFile('my-bangumi.html');
export const loginHtml = readHtmlFile('login.html');
export const registerHtml = readHtmlFile('register.html');
export const forgotPasswordHtml = readHtmlFile('forgot-password.html');
export const expandEpisodeTableHtml = readHtmlFile('expand-episode-table.html');

// For backward compatibility with existing tests
export const seasonListHtml = indexHtml;
export const bangumiRowHtml = seasonHtml;
export const dayRecordHtml = dayHtml;
export const subgroupHtml = searchHtml;
export const bangumiDetailHtml = bangumiHtml;
export const recordDetailHtml = episodeHtml;
export const subgroupPageHtml = searchHtml;
