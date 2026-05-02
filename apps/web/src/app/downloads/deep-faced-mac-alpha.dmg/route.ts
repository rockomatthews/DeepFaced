import { NextResponse } from "next/server";

const downloadUrl = process.env.MACOS_DMG_DOWNLOAD_URL;

export function GET(request: Request) {
  if (!downloadUrl) {
    return NextResponse.redirect(new URL("/download?download=missing", request.url), 302);
  }

  try {
    return NextResponse.redirect(new URL(downloadUrl), 302);
  } catch {
    return NextResponse.redirect(new URL("/download?download=invalid", request.url), 302);
  }
}
