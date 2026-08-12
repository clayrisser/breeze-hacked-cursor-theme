FROM debian:bookworm-slim

# inkscape renders the cursor SVG to pixmaps; xcursorgen (shipped in
# x11-apps) assembles them into Xcursor files.
RUN apt-get update && \
    apt-get install -y --no-install-recommends inkscape x11-apps && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /work
CMD ["./build.sh"]
