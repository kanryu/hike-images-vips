HIKEC = go run ../../../cmd/hikec
TARGET = windows
OUTPUT = load_image.exe

.PHONY: all emit-ir build run clean

all: build

emit-ir:
	$(HIKEC) emit-ir -target $(TARGET) -o main.ll main.hike

build: $(OUTPUT)

$(OUTPUT): main.hike hike.mod ../../hike.mod
	$(HIKEC) build -target $(TARGET) main.hike -o $(OUTPUT)

run: build input.svg
	./$(OUTPUT)

clean:
	rm -f main.ll $(OUTPUT) output.png *.dll
