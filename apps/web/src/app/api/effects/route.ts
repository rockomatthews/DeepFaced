import { NextResponse } from "next/server";
import { communityFaces } from "@deep-faced/effects";

export function GET(request: Request) {
  const effects = communityFaces
    .filter((face) => face.visibility === "public" && face.reviewStatus === "approved")
    .map((face) => ({
      id: face.id,
      slug: face.slug,
      name: face.name,
      creator: {
        id: face.creator.id,
        handle: face.creator.handle,
        displayName: face.creator.displayName,
        verified: face.creator.verified,
      },
      kind: face.kind,
      description: face.description,
      assetURL: new URL(face.assetPath, request.url).toString(),
      thumbnailURL: face.thumbnailPath ? new URL(face.thumbnailPath, request.url).toString() : null,
      featureFlags: face.featureFlags,
      packageSizeMb: face.packageSizeMb,
      deepARStudioVersion: face.deepArStudioVersion,
    }));

  return NextResponse.json({ effects });
}
