import struct, sys

data = open(sys.argv[1], 'rb').read()
print('@00000000')
for i in range(0, len(data), 4):
    print(f'{struct.unpack_from("<I", data, i)[0]:08x}')
