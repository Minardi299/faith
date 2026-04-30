import verses from '@/assets/data/dhammapada.json';

export type Verse = {
  number: number;
  chapter: number;
  chapterTitle: string;
  text: string;
};

const VERSES = verses as Verse[];

export function verseForDate(date: Date): Verse {
  const start = Date.UTC(date.getUTCFullYear(), 0, 0);
  const dayOfYear = Math.floor((date.getTime() - start) / 86_400_000);
  return VERSES[dayOfYear % VERSES.length];
}

export function dailyTimeline(days: number, from: Date = new Date()): { date: Date; verse: Verse }[] {
  const startOfDay = new Date(from);
  startOfDay.setHours(0, 0, 0, 0);
  return Array.from({ length: days }, (_, i) => {
    const date = new Date(startOfDay.getTime() + i * 86_400_000);
    return { date, verse: verseForDate(date) };
  });
}
