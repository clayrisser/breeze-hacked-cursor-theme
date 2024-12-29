from pathlib import Path
from shutil import which, copy
from subprocess import Popen, DEVNULL, PIPE

src = Path("src")
size=24 # size at 1x scale
dpi=90 # dpi at 1x scale
scales = [1, 1.5, 2]

SVG = src / "cursors.svg"
INDEX = src / "index.theme"
ALIASES= src / "cursorList"

########### PARSE CONFIGS ###########
config = src  / "config"

cursorpositions = {}
for c in config.iterdir():
    with open(c, "r") as f:
        cursorpositions[c.stem] = [ tuple(map(int, s.split()[1:3]))
                                    for s in f if s.startswith(f"{size}")]

with open(INDEX) as ind:
    ind.readline()
    line = ind.readline().strip()
    OUTPUT = Path(".") / line.split("=")[1].replace(" ", "_")


########### REQUIREMENTS ###########
print("Checking Requirements...", end="\r", flush=True)

if not SVG.exists():
    print(f"\nFAIL: {SVG} missing in src")
    exit(1)

if not INDEX.exists():
    print(f"\nFAIL: {INDEX} missing in src")
    exit(1)

if which("inkscape") is None:
    print("\nFAIL: inkscape must be intalled")

if which("xcursorgen") is None:
    print("\nFAIL: xcursorgen must be intalled")

print("Checking Requirements... DONE")


########### FOLDERS ###########
print("Making Folders...", end="", flush=True)
build = Path("build")
build.mkdir(exist_ok=True)

for s in scales:
    (build / f"x{s}").mkdir(exist_ok=True)

OUTPUT.mkdir(exist_ok=True)
(OUTPUT / "cursors").mkdir(exist_ok=True)

print("DONE")


########### PIXMAPS ###########

picprocs = []

for cursor in cursorpositions:
    print(f"\033[0KGenerating cursor pixmaps... {cursor}", end="\r", flush=True)
    positions = cursorpositions[cursor]
    nametemplate = f"{cursor}"
    if len(positions) > 1:
        nametemplate = f"{cursor}-{{:02}}"

    for scale in scales:
        scaledir = build / f"x{scale}"
        for i, _ in enumerate(positions):
            name = nametemplate.format(i + 1)
            outfile = scaledir / f"{name}.png"
            picprocs.append(
                Popen(["inkscape", SVG.as_posix(), "-i", name, "-d", f"{dpi * scale}", "-o", outfile.as_posix()], stderr=DEVNULL)
            )

for p in picprocs:
    p.wait()

print("\033[0KGenerating cursor pixmaps... DONE")


########### THEME ###########
for cursor in cursorpositions:
    print(f"Generating cursor theme... {cursor}\r", end="", flush=True)
    poss = cursorpositions[cursor]
    multi = len(poss) > 1
    message ="\n".join(
        f"{scale * size:.0f} {scale * x:.0f} {scale * y:.0f} x{scale}/{cursor}{f"-{i + 1:02}" if multi else ""}.png {"30" if multi else ""}"
            for scale in scales
            for i, (x, y) in enumerate(poss)
    )

    gen = Popen(["xcursorgen", "-p", "build", "-", (OUTPUT / "cursors" / cursor).as_posix()], stdin=PIPE)
    gen.communicate(bytes(message, encoding="utf8"))

print("Generating cursor theme... DONE                   ")


########### SHORTCUTS ###########

print("Generating shortcuts...", end="", flush=True)

cursors = OUTPUT / "cursors"
with open(ALIASES) as aliases:
    for alias in aliases:
        src, dst = alias.split()
        src = cursors / src
        if not src.exists():
            src.symlink_to(dst)

print("DONE")

########### INDEX ###########

print("Copying Theme Index...\r", end="", flush=True)

copy(src= INDEX, dst= OUTPUT / "index.theme")

print("\033[0KCopying Theme Index... DONE")

print("COMPLETE!")
