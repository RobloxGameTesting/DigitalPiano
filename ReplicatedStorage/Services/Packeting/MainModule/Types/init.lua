local v = nil
local v2 = nil
local bufferLength = nil
local bufferOffset = nil
local instances = nil
local instancesOffset = nil

local v3 = {}
local v4 = {}

local function Allocate(p: number) -- 75 equivalent calls inferred from this helper
	local v5 = bufferOffset + p

	if bufferLength < v5 then
		while bufferLength < v5 do
			bufferLength *= 2
		end

		local buf = buffer.create(bufferLength)
		buffer.copy(buf, 0, v2, 0, bufferOffset)
		v.Buffer = buf
		v2 = buf
	end
end

local function ReadS8() -- 1 equivalent call inferred from this helper
	local s8 = buffer.readi8(v2, bufferOffset)
	bufferOffset += 1
	return s8
end
local function WriteS8(value: number) -- 1 equivalent call inferred from this helper
	buffer.writei8(v2, bufferOffset, value)
	bufferOffset += 1
end
local function ReadS16() -- 18 equivalent calls inferred from this helper
	local s16 = buffer.readi16(v2, bufferOffset)
	bufferOffset += 2
	return s16
end
local function WriteS16(value: number) -- 18 equivalent calls inferred from this helper
	buffer.writei16(v2, bufferOffset, value)
	bufferOffset += 2
end
local function ReadS24() -- 1 equivalent call inferred from this helper
	local s24 = buffer.readbits(v2, bufferOffset * 8, 24) - 8388608
	bufferOffset += 3
	return s24
end
local function WriteS24(p: number) -- 1 equivalent call inferred from this helper
	buffer.writebits(v2, bufferOffset * 8, 24, p + 8388608)
	bufferOffset += 3
end
local function ReadS32() -- 1 equivalent call inferred from this helper
	local s32 = buffer.readi32(v2, bufferOffset)
	bufferOffset += 4
	return s32
end
local function WriteS32(value: number) -- 1 equivalent call inferred from this helper
	buffer.writei32(v2, bufferOffset, value)
	bufferOffset += 4
end
local function ReadU8() -- 48 equivalent calls inferred from this helper
	local u8 = buffer.readu8(v2, bufferOffset)
	bufferOffset += 1
	return u8
end
local function WriteU8(value: number) -- 75 equivalent calls inferred from this helper
	buffer.writeu8(v2, bufferOffset, value)
	bufferOffset += 1
end
local function ReadU16() -- 15 equivalent calls inferred from this helper
	local u16 = buffer.readu16(v2, bufferOffset)
	bufferOffset += 2
	return u16
end
local function WriteU16(value: number) -- 15 equivalent calls inferred from this helper
	buffer.writeu16(v2, bufferOffset, value)
	bufferOffset += 2
end
local function ReadU24() -- 3 equivalent calls inferred from this helper
	local u24 = buffer.readbits(v2, bufferOffset * 8, 24)
	bufferOffset += 3
	return u24
end
local function WriteU24(value: number) -- 3 equivalent calls inferred from this helper
	buffer.writebits(v2, bufferOffset * 8, 24, value)
	bufferOffset += 3
end
local function ReadU32() -- 3 equivalent calls inferred from this helper
	local u32 = buffer.readu32(v2, bufferOffset)
	bufferOffset += 4
	return u32
end
local function WriteU32(value: number) -- 3 equivalent calls inferred from this helper
	buffer.writeu32(v2, bufferOffset, value)
	bufferOffset += 4
end
local function ReadF32() -- 45 equivalent calls inferred from this helper
	local f32 = buffer.readf32(v2, bufferOffset)
	bufferOffset += 4
	return f32
end
local function WriteF32(value: number) -- 45 equivalent calls inferred from this helper
	buffer.writef32(v2, bufferOffset, value)
	bufferOffset += 4
end
local function ReadF64() -- 2 equivalent calls inferred from this helper
	local f64 = buffer.readf64(v2, bufferOffset)
	bufferOffset += 8
	return f64
end
local function WriteF64(value: number) -- 4 equivalent calls inferred from this helper
	buffer.writef64(v2, bufferOffset, value)
	bufferOffset += 8
end
local function ReadString(count: number) -- 3 equivalent calls inferred from this helper
	local str = buffer.readstring(v2, bufferOffset, count)
	bufferOffset += count
	return str
end
local function WriteString(str: string) -- 3 equivalent calls inferred from this helper
	buffer.writestring(v2, bufferOffset, str)
	bufferOffset += #str
end
local function ReadBuffer(size: number) -- 3 equivalent calls inferred from this helper
	local buf = buffer.create(size)
	buffer.copy(buf, 0, v2, bufferOffset, size)
	bufferOffset += size
	return buf
end
local function WriteBuffer(buf: buffer) -- 3 equivalent calls inferred from this helper
	buffer.copy(v2, bufferOffset, buf)
	bufferOffset += buffer.len(buf)
end
local function ReadInstance() -- 2 equivalent calls inferred from this helper
	instancesOffset += 1
	return instances[instancesOffset]
end
local function WriteInstance(p) -- 2 equivalent calls inferred from this helper
	instancesOffset += 1
	instances[instancesOffset] = p
end

local function ReadF16()
	local v5 = bufferOffset * 8
	bufferOffset += 2
	local v6 = buffer.readbits(v2, v5 + 0, 10)
	local v7 = buffer.readbits(v2, v5 + 10, 5)
	local v8 = buffer.readbits(v2, v5 + 15, 1)

	if v6 == 0 then
		if v7 == 0 then
			return 0
		elseif v7 == 31 then
			return if v8 == 0 then 1e999 else -1e999
		end
	elseif v7 == 31 then
		return (0 / 0)
	end

	if v8 == 0 then
		return (v6 / 1024 + 1) * 2 ^ (v7 - 15)
	end

	return -(v6 / 1024 + 1) * 2 ^ (v7 - 15)
end

local function WriteF16(p: number)
	local v5 = bufferOffset * 8
	bufferOffset += 2

	if p == 0 then
		buffer.writebits(v2, v5, 16, 0)
		return
	end

	if p >= 65520 then
		buffer.writebits(v2, v5, 16, 31744)
		return
	end

	if p <= -65520 then
		buffer.writebits(v2, v5, 16, 64512)
		return
	end

	if p ~= p then
		buffer.writebits(v2, v5, 16, 31745)
		return
	end

	local v6

	if p < 0 then
		p = -p
		v6 = 1
	else
		v6 = 0
	end

	local v7, v8 = math.frexp(p)
	buffer.writebits(v2, v5 + 0, 10, v7 * 2048 - 1023.5)
	buffer.writebits(v2, v5 + 10, 5, v8 + 14)
	buffer.writebits(v2, v5 + 15, 1, v6)
end

local function ReadF24()
	local v5 = bufferOffset * 8
	bufferOffset += 3
	local v6 = buffer.readbits(v2, v5 + 0, 17)
	local v7 = buffer.readbits(v2, v5 + 17, 6)
	local v8 = buffer.readbits(v2, v5 + 23, 1)

	if v6 == 0 then
		if v7 == 0 then
			return 0
		elseif v7 == 63 then
			return if v8 == 0 then 1e999 else -1e999
		end
	elseif v7 == 63 then
		return (0 / 0)
	end

	if v8 == 0 then
		return (v6 / 131072 + 1) * 2 ^ (v7 - 31)
	end

	return -(v6 / 131072 + 1) * 2 ^ (v7 - 31)
end

local function WriteF24(p: number)
	local v5 = bufferOffset * 8
	bufferOffset += 3

	if p == 0 then
		buffer.writebits(v2, v5, 24, 0)
		return
	end

	if p >= 4294959104 then
		buffer.writebits(v2, v5, 24, 8257536)
		return
	end

	if p <= -4294959104 then
		buffer.writebits(v2, v5, 24, 16646144)
		return
	end

	if p ~= p then
		buffer.writebits(v2, v5, 24, 8257537)
		return
	end

	local v6

	if p < 0 then
		p = -p
		v6 = 1
	else
		v6 = 0
	end

	local v7, v8 = math.frexp(p)
	buffer.writebits(v2, v5 + 0, 17, v7 * 262144 - 131071.5)
	buffer.writebits(v2, v5 + 17, 6, v8 + 30)
	buffer.writebits(v2, v5 + 23, 1, v6)
end

local reads = {}

function reads.Any()
	return v3[ReadU8()]() -- inferred equivalent call
end

local writes = {}

function writes.Any(p)
	v4[typeof(p)](p)
end

function reads.Nil(): nil
	return nil
end
function writes.Nil(_: nil) end

function reads.NumberS8()
	return ReadS8() -- inferred equivalent call
end
function writes.NumberS8(value: number)
	Allocate(1) -- inferred equivalent call
	WriteS8(value) -- inferred equivalent call
end

function reads.NumberS16()
	return ReadS16() -- inferred equivalent call
end
function writes.NumberS16(value: number)
	Allocate(2) -- inferred equivalent call
	WriteS16(value) -- inferred equivalent call
end

function reads.NumberS24()
	return ReadS24() -- inferred equivalent call
end
function writes.NumberS24(p: number)
	Allocate(3) -- inferred equivalent call
	WriteS24(p) -- inferred equivalent call
end

function reads.NumberS32()
	return ReadS32() -- inferred equivalent call
end
function writes.NumberS32(value: number)
	Allocate(4) -- inferred equivalent call
	WriteS32(value) -- inferred equivalent call
end

function reads.NumberU8()
	return ReadU8() -- inferred equivalent call
end
function writes.NumberU8(value: number)
	Allocate(1) -- inferred equivalent call
	WriteU8(value) -- inferred equivalent call
end

function reads.NumberU16()
	return ReadU16() -- inferred equivalent call
end
function writes.NumberU16(value: number)
	Allocate(2) -- inferred equivalent call
	WriteU16(value) -- inferred equivalent call
end

function reads.NumberU24()
	return ReadU24() -- inferred equivalent call
end
function writes.NumberU24(value: number)
	Allocate(3) -- inferred equivalent call
	WriteU24(value) -- inferred equivalent call
end

function reads.NumberU32()
	return ReadU32() -- inferred equivalent call
end
function writes.NumberU32(value: number)
	Allocate(4) -- inferred equivalent call
	WriteU32(value) -- inferred equivalent call
end

function reads.NumberF16()
	return ReadF16()
end
function writes.NumberF16(p: number)
	Allocate(2) -- inferred equivalent call
	WriteF16(p)
end

function reads.NumberF24()
	return ReadF24()
end
function writes.NumberF24(p: number)
	Allocate(3) -- inferred equivalent call
	WriteF24(p)
end

function reads.NumberF32()
	return ReadF32() -- inferred equivalent call
end
function writes.NumberF32(value: number)
	Allocate(4) -- inferred equivalent call
	WriteF32(value) -- inferred equivalent call
end

function reads.NumberF64()
	return ReadF64() -- inferred equivalent call
end
function writes.NumberF64(value: number)
	Allocate(8) -- inferred equivalent call
	WriteF64(value) -- inferred equivalent call
end

function reads.String()
	return ReadString(ReadU8()) -- inferred equivalent call
end
function writes.String(list: string)
	local count = #list
	Allocate(count + 1) -- inferred equivalent call
	WriteU8(count) -- inferred equivalent call
	WriteString(list) -- inferred equivalent call
end

function reads.StringLong()
	return ReadString(ReadU16()) -- inferred equivalent call
end
function writes.StringLong(list: string)
	local count = #list
	Allocate(count + 2) -- inferred equivalent call
	WriteU16(count) -- inferred equivalent call
	WriteString(list) -- inferred equivalent call
end

function reads.Buffer()
	return ReadBuffer(ReadU8()) -- inferred equivalent call
end
function writes.Buffer(buf: buffer)
	local v5 = buffer.len(buf)
	Allocate(1 + v5) -- inferred equivalent call
	WriteU8(v5) -- inferred equivalent call
	WriteBuffer(buf) -- inferred equivalent call
end

function reads.BufferLong()
	return ReadBuffer(ReadU16()) -- inferred equivalent call
end
function writes.BufferLong(buf: buffer)
	local v5 = buffer.len(buf)
	Allocate(2 + v5) -- inferred equivalent call
	WriteU16(v5) -- inferred equivalent call
	WriteBuffer(buf) -- inferred equivalent call
end

function reads.Instance()
	return ReadInstance() -- inferred equivalent call
end
function writes.Instance(p)
	WriteInstance(p) -- inferred equivalent call
end

function reads.Boolean8(): boolean
	return ReadU8() == 1 -- inferred equivalent call
end
function writes.Boolean8(flag: boolean)
	Allocate(1) -- inferred equivalent call
	buffer.writeu8(v2, bufferOffset, flag and 1 or 0)
	bufferOffset += 1
end

function reads.NumberRange()
	return NumberRange.new(ReadF32(), ReadF32()) -- inferred equivalent call
end
function writes.NumberRange(range: NumberRange)
	Allocate(8) -- inferred equivalent call
	WriteF32(range.Min) -- inferred equivalent call
	WriteF32(range.Max) -- inferred equivalent call
end

function reads.BrickColor()
	return BrickColor.new(ReadU16()) -- inferred equivalent call
end
function writes.BrickColor(p)
	Allocate(2) -- inferred equivalent call
	WriteU16(p.Number) -- inferred equivalent call
end

function reads.Color3()
	return Color3.fromRGB(ReadU8(), ReadU8(), ReadU8()) -- inferred equivalent call
end
function writes.Color3(color: Color3)
	Allocate(3) -- inferred equivalent call
	WriteU8(color.R * 255 + 0.5) -- inferred equivalent call
	WriteU8(color.G * 255 + 0.5) -- inferred equivalent call
	WriteU8(color.B * 255 + 0.5) -- inferred equivalent call
end

function reads.UDim()
	return UDim.new(ReadS16() / 1000, ReadS16()) -- inferred equivalent call
end
function writes.UDim(udim: UDim)
	Allocate(4) -- inferred equivalent call
	WriteS16(udim.Scale * 1000) -- inferred equivalent call
	WriteS16(udim.Offset) -- inferred equivalent call
end

function reads.UDim2()
	local v5 = ReadS16() / 1000 -- inferred equivalent call
	local readS16 = ReadS16() -- inferred equivalent call
	return UDim2.new(v5, readS16, ReadS16() / 1000, ReadS16()) -- inferred equivalent call
end
function writes.UDim2(udim: UDim2)
	Allocate(8) -- inferred equivalent call
	WriteS16(udim.X.Scale * 1000) -- inferred equivalent call
	WriteS16(udim.X.Offset) -- inferred equivalent call
	WriteS16(udim.Y.Scale * 1000) -- inferred equivalent call
	WriteS16(udim.Y.Offset) -- inferred equivalent call
end

function reads.Rect()
	return Rect.new(ReadF32(), ReadF32(), ReadF32(), ReadF32()) -- inferred equivalent call
end
function writes.Rect(rect: Rect)
	Allocate(16) -- inferred equivalent call
	WriteF32(rect.Min.X) -- inferred equivalent call
	WriteF32(rect.Min.Y) -- inferred equivalent call
	WriteF32(rect.Max.X) -- inferred equivalent call
	WriteF32(rect.Max.Y) -- inferred equivalent call
end

function reads.Vector2S16()
	return Vector2.new(ReadS16(), ReadS16()) -- inferred equivalent call
end
function writes.Vector2S16(vector2: Vector2)
	Allocate(4) -- inferred equivalent call
	WriteS16(vector2.X) -- inferred equivalent call
	WriteS16(vector2.Y) -- inferred equivalent call
end

function reads.Vector2F24()
	return Vector2.new(ReadF24(), ReadF24())
end
function writes.Vector2F24(vector2: Vector2)
	Allocate(6) -- inferred equivalent call
	WriteF24(vector2.X)
	WriteF24(vector2.Y)
end

function reads.Vector2F32()
	return Vector2.new(ReadF32(), ReadF32()) -- inferred equivalent call
end
function writes.Vector2F32(vector2: Vector2)
	Allocate(8) -- inferred equivalent call
	WriteF32(vector2.X) -- inferred equivalent call
	WriteF32(vector2.Y) -- inferred equivalent call
end

function reads.Vector3S16()
	return (Vector3.new(ReadS16(), ReadS16(), ReadS16())) -- inferred equivalent call
end
function writes.Vector3S16(vector3: Vector3)
	Allocate(6) -- inferred equivalent call
	WriteS16(vector3.X) -- inferred equivalent call
	WriteS16(vector3.Y) -- inferred equivalent call
	WriteS16(vector3.Z) -- inferred equivalent call
end

function reads.Vector3F24()
	return (Vector3.new(ReadF24(), ReadF24(), ReadF24()))
end
function writes.Vector3F24(vector3: Vector3)
	Allocate(9) -- inferred equivalent call
	WriteF24(vector3.X)
	WriteF24(vector3.Y)
	WriteF24(vector3.Z)
end

function reads.Vector3F32()
	return (Vector3.new(ReadF32(), ReadF32(), ReadF32())) -- inferred equivalent call
end
function writes.Vector3F32(vector3: Vector3)
	Allocate(12) -- inferred equivalent call
	WriteF32(vector3.X) -- inferred equivalent call
	WriteF32(vector3.Y) -- inferred equivalent call
	WriteF32(vector3.Z) -- inferred equivalent call
end

function reads.NumberU4()
	local v5 = bufferOffset * 8
	bufferOffset += 1
	return { buffer.readbits(v2, v5 + 0, 4), buffer.readbits(v2, v5 + 4, 4) }
end

function writes.NumberU4(list)
	Allocate(1) -- inferred equivalent call
	local v5 = bufferOffset * 8
	bufferOffset += 1
	buffer.writebits(v2, v5 + 0, 4, list[1])
	buffer.writebits(v2, v5 + 4, 4, list[2])
end

function reads.BooleanNumber()
	local v5 = bufferOffset * 8
	bufferOffset += 1
	return {
		Boolean = buffer.readbits(v2, v5 + 0, 1) == 1,
		Number = buffer.readbits(v2, v5 + 1, 7)
	}
end

function writes.BooleanNumber(p)
	Allocate(1) -- inferred equivalent call
	local v5 = bufferOffset * 8
	bufferOffset += 1
	buffer.writebits(v2, v5 + 0, 1, p.Boolean and 1 or 0)
	buffer.writebits(v2, v5 + 1, 7, p.Number)
end

function reads.Boolean1()
	local v5 = bufferOffset * 8
	bufferOffset += 1
	return {
		buffer.readbits(v2, v5 + 0, 1) == 1,
		buffer.readbits(v2, v5 + 1, 1) == 1,
		buffer.readbits(v2, v5 + 2, 1) == 1,
		buffer.readbits(v2, v5 + 3, 1) == 1,
		buffer.readbits(v2, v5 + 4, 1) == 1,
		buffer.readbits(v2, v5 + 5, 1) == 1,
		buffer.readbits(v2, v5 + 6, 1) == 1,
		buffer.readbits(v2, v5 + 7, 1) == 1
	}
end

function writes.Boolean1(list)
	Allocate(1) -- inferred equivalent call
	local v5 = bufferOffset * 8
	bufferOffset += 1
	buffer.writebits(v2, v5 + 0, 1, list[1] and 1 or 0)
	buffer.writebits(v2, v5 + 1, 1, list[2] and 1 or 0)
	buffer.writebits(v2, v5 + 2, 1, list[3] and 1 or 0)
	buffer.writebits(v2, v5 + 3, 1, list[4] and 1 or 0)
	buffer.writebits(v2, v5 + 4, 1, list[5] and 1 or 0)
	buffer.writebits(v2, v5 + 5, 1, list[6] and 1 or 0)
	buffer.writebits(v2, v5 + 6, 1, list[7] and 1 or 0)
	buffer.writebits(v2, v5 + 7, 1, list[8] and 1 or 0)
end

function reads.CFrameF24U8()
	return CFrame.fromEulerAnglesXYZ(
		ReadU8() / 40.58451048843331, -- inferred equivalent call
		ReadU8() / 40.58451048843331, -- inferred equivalent call
		ReadU8() / 40.58451048843331 -- inferred equivalent call
	) + Vector3.new(ReadF24(), ReadF24(), ReadF24())
end

function writes.CFrameF24U8(cframe: CFrame)
	local eulerAnglesXYZ, v5, v6 = cframe:ToEulerAnglesXYZ()
	Allocate(12) -- inferred equivalent call
	WriteU8(eulerAnglesXYZ * 40.58451048843331 + 0.5) -- inferred equivalent call
	WriteU8(v5 * 40.58451048843331 + 0.5) -- inferred equivalent call
	WriteU8(v6 * 40.58451048843331 + 0.5) -- inferred equivalent call
	WriteF24(cframe.X)
	WriteF24(cframe.Y)
	WriteF24(cframe.Z)
end

function reads.CFrameF32U8()
	return CFrame.fromEulerAnglesXYZ(
		ReadU8() / 40.58451048843331, -- inferred equivalent call
		ReadU8() / 40.58451048843331, -- inferred equivalent call
		ReadU8() / 40.58451048843331 -- inferred equivalent call
	) + Vector3.new(ReadF32(), ReadF32(), ReadF32()) -- inferred equivalent call
end

function writes.CFrameF32U8(cframe: CFrame)
	local eulerAnglesXYZ, v5, v6 = cframe:ToEulerAnglesXYZ()
	Allocate(15) -- inferred equivalent call
	WriteU8(eulerAnglesXYZ * 40.58451048843331 + 0.5) -- inferred equivalent call
	WriteU8(v5 * 40.58451048843331 + 0.5) -- inferred equivalent call
	WriteU8(v6 * 40.58451048843331 + 0.5) -- inferred equivalent call
	WriteF32(cframe.X) -- inferred equivalent call
	WriteF32(cframe.Y) -- inferred equivalent call
	WriteF32(cframe.Z) -- inferred equivalent call
end

function reads.CFrameF32U16()
	return CFrame.fromEulerAnglesXYZ(
		ReadU16() / 10430.219195527361, -- inferred equivalent call
		ReadU16() / 10430.219195527361, -- inferred equivalent call
		ReadU16() / 10430.219195527361 -- inferred equivalent call
	) + Vector3.new(ReadF32(), ReadF32(), ReadF32()) -- inferred equivalent call
end

function writes.CFrameF32U16(cframe: CFrame)
	local eulerAnglesXYZ, v5, v6 = cframe:ToEulerAnglesXYZ()
	Allocate(18) -- inferred equivalent call
	WriteU16(eulerAnglesXYZ * 10430.219195527361 + 0.5) -- inferred equivalent call
	WriteU16(v5 * 10430.219195527361 + 0.5) -- inferred equivalent call
	WriteU16(v6 * 10430.219195527361 + 0.5) -- inferred equivalent call
	WriteF32(cframe.X) -- inferred equivalent call
	WriteF32(cframe.Y) -- inferred equivalent call
	WriteF32(cframe.Z) -- inferred equivalent call
end

function reads.Region3()
	return Region3.new(Vector3.new(ReadF32(), ReadF32(), ReadF32()), (Vector3.new(ReadF32(), ReadF32(), ReadF32()))) -- inferred equivalent call
end

function writes.Region3(instance)
	local halfSize = instance.Size / 2
	local v5 = instance.CFrame.Position - halfSize
	local v6 = instance.CFrame.Position + halfSize
	Allocate(24) -- inferred equivalent call
	WriteF32(v5.X) -- inferred equivalent call
	WriteF32(v5.Y) -- inferred equivalent call
	WriteF32(v5.Z) -- inferred equivalent call
	WriteF32(v6.X) -- inferred equivalent call
	WriteF32(v6.Y) -- inferred equivalent call
	WriteF32(v6.Z) -- inferred equivalent call
end

function reads.NumberSequence()
	local readU8 = ReadU8() -- inferred equivalent call
	local v5 = table.create(readU8)

	for _ = 1, readU8 do
		local v6 = ReadU8() / 255 -- inferred equivalent call
		local v7 = ReadU8() / 255 -- inferred equivalent call
		table.insert(v5, NumberSequenceKeypoint.new(v6, v7, ReadU8() / 255)) -- inferred equivalent call
	end

	return NumberSequence.new(v5)
end

function writes.NumberSequence(sequence)
	local count = #sequence.Keypoints
	Allocate(count * 3 + 1) -- inferred equivalent call
	WriteU8(count) -- inferred equivalent call

	for _, keypoint in sequence.Keypoints do
		WriteU8(keypoint.Time * 255 + 0.5) -- inferred equivalent call
		WriteU8(keypoint.Value * 255 + 0.5) -- inferred equivalent call
		WriteU8(keypoint.Envelope * 255 + 0.5) -- inferred equivalent call
	end
end

local types = {
	Any = "Any",
	Nil = "Nil",
	NumberS8 = "NumberS8",
	NumberS16 = "NumberS16",
	NumberS24 = "NumberS24",
	NumberS32 = "NumberS32",
	NumberU8 = "NumberU8",
	NumberU16 = "NumberU16",
	NumberU24 = "NumberU24",
	NumberU32 = "NumberU32",
	NumberF16 = "NumberF16",
	NumberF24 = "NumberF24",
	NumberF32 = "NumberF32",
	NumberF64 = "NumberF64",
	String = "String",
	StringLong = "StringLong",
	Buffer = "Buffer",
	BufferLong = "BufferLong",
	Instance = "Instance",
	Boolean8 = "Boolean8",
	NumberRange = "NumberRange",
	BrickColor = "BrickColor",
	Color3 = "Color3",
	UDim = "UDim",
	UDim2 = "UDim2",
	Rect = "Rect",
	Vector2S16 = "Vector2S16",
	Vector2F24 = "Vector2F24",
	Vector2F32 = "Vector2F32",
	Vector3S16 = "Vector3S16",
	Vector3F24 = "Vector3F24",
	Vector3F32 = "Vector3F32",
	NumberU4 = "NumberU4",
	BooleanNumber = "BooleanNumber",
	Boolean1 = "Boolean1",
	CFrameF24U8 = "CFrameF24U8",
	CFrameF32U8 = "CFrameF32U8",
	CFrameF32U16 = "CFrameF32U16",
	Region3 = "Region3",
	NumberSequence = "NumberSequence",
	ColorSequence = "ColorSequence"
}

function reads.ColorSequence()
	local readU8 = ReadU8() -- inferred equivalent call
	local v5 = table.create(readU8)

	for _ = 1, readU8 do
		local v6 = ReadU8() / 255 -- inferred equivalent call

		table.insert(v5, ColorSequenceKeypoint.new(v6, Color3.fromRGB(ReadU8(), ReadU8(), ReadU8()))) -- inferred equivalent call
	end

	return ColorSequence.new(v5)
end

function writes.ColorSequence(sequence)
	local count = #sequence.Keypoints
	Allocate(count * 4 + 1) -- inferred equivalent call
	WriteU8(count) -- inferred equivalent call

	for _, keypoint in sequence.Keypoints do
		WriteU8(keypoint.Time * 255 + 0.5) -- inferred equivalent call
		WriteU8(keypoint.Value.R * 255 + 0.5) -- inferred equivalent call
		WriteU8(keypoint.Value.G * 255 + 0.5) -- inferred equivalent call
		WriteU8(keypoint.Value.B * 255 + 0.5) -- inferred equivalent call
	end
end

local Characters = require(script.Characters)
local v5 = {}

for k, character in Characters do
	v5[character] = k
end

local v6 = math.ceil((math.log(#Characters + 1, 2)))
local v7 = v6 / 8
types.Characters = "Characters"
function reads.Characters()
	local readU8 = ReadU8() -- inferred equivalent call
	local v8 = table.create(readU8)
	local v9 = bufferOffset * 8
	bufferOffset += math.ceil(readU8 * v7)

	for _ = 1, readU8 do
		table.insert(v8, Characters[buffer.readbits(v2, v9, v6)])
		v9 += v6
	end

	return table.concat(v8)
end

function writes.Characters(value: string)
	local count = #value
	local v8 = math.ceil(count * v7)
	Allocate(v8 + 1) -- inferred equivalent call
	WriteU8(count) -- inferred equivalent call
	local v9 = bufferOffset * 8

	for i = 1, count do
		buffer.writebits(v2, v9, v6, v5[value:sub(i, i)])
		v9 += v6
	end

	bufferOffset += v8
end

local Enums = require(script.Enums)
local v8 = {}

for k, enum in Enums do
	v8[enum] = k
end

types.EnumItem = "EnumItem"
function reads.EnumItem()
	return Enums[ReadU8()]:FromValue(ReadU16()) -- inferred equivalent call
end
function writes.EnumItem(p)
	Allocate(3) -- inferred equivalent call
	WriteU8(v8[p.EnumType]) -- inferred equivalent call
	WriteU16(p.Value) -- inferred equivalent call
end

local Static1 = require(script.Static1)
local v9 = {}

for k, v10 in Static1 do
	v9[v10] = k
end

types.Static1 = "Static1"
function reads.Static1()
	return Static1[ReadU8()] -- inferred equivalent call
end
function writes.Static1(p)
	Allocate(1) -- inferred equivalent call
	WriteU8(v9[p] or 0) -- inferred equivalent call
end

local Static2 = require(script.Static2)
local v10 = {}

for k, v11 in Static2 do
	v10[v11] = k
end

types.Static2 = "Static2"
function reads.Static2()
	return Static2[ReadU8()] -- inferred equivalent call
end
function writes.Static2(p)
	Allocate(1) -- inferred equivalent call
	WriteU8(v10[p] or 0) -- inferred equivalent call
end

local Static3 = require(script.Static3)
local v11 = {}

for k, v12 in Static3 do
	v11[v12] = k
end

types.Static3 = "Static3"
function reads.Static3()
	return Static3[ReadU8()] -- inferred equivalent call
end
function writes.Static3(p)
	Allocate(1) -- inferred equivalent call
	WriteU8(v11[p] or 0) -- inferred equivalent call
end

v3[0] = function(): nil
	return nil
end
v4["nil"] = function(_: nil)
	Allocate(1) -- inferred equivalent call
	WriteU8(0) -- inferred equivalent call
end

v3[1] = function()
	return -ReadU8() -- inferred equivalent call
end
v3[2] = function()
	return -ReadU16() -- inferred equivalent call
end
v3[3] = function()
	return -ReadU24() -- inferred equivalent call
end
v3[4] = function()
	return -ReadU32() -- inferred equivalent call
end
v3[5] = function()
	return ReadU8() -- inferred equivalent call
end
v3[6] = function()
	return ReadU16() -- inferred equivalent call
end
v3[7] = function()
	return ReadU24() -- inferred equivalent call
end
v3[8] = function()
	return ReadU32() -- inferred equivalent call
end
v3[9] = function()
	return ReadF32() -- inferred equivalent call
end
v3[10] = function()
	return ReadF64() -- inferred equivalent call
end
function v4.number(value: number)
	if value % 1 == 0 then
		if value < 0 then
			if value > -256 then
				Allocate(2) -- inferred equivalent call
				WriteU8(1) -- inferred equivalent call
				WriteU8(-value) -- inferred equivalent call
			elseif value > -65536 then
				Allocate(3) -- inferred equivalent call
				WriteU8(2) -- inferred equivalent call
				WriteU16(-value) -- inferred equivalent call
			elseif value > -16777216 then
				Allocate(4) -- inferred equivalent call
				WriteU8(3) -- inferred equivalent call
				WriteU24(-value) -- inferred equivalent call
			elseif value > -4294967296 then
				Allocate(5) -- inferred equivalent call
				WriteU8(4) -- inferred equivalent call
				WriteU32(-value) -- inferred equivalent call
			else
				Allocate(9) -- inferred equivalent call
				WriteU8(10) -- inferred equivalent call
				WriteF64(value) -- inferred equivalent call
			end
		elseif value < 256 then
			Allocate(2) -- inferred equivalent call
			WriteU8(5) -- inferred equivalent call
			WriteU8(value) -- inferred equivalent call
		elseif value < 65536 then
			Allocate(3) -- inferred equivalent call
			WriteU8(6) -- inferred equivalent call
			WriteU16(value) -- inferred equivalent call
		elseif value < 16777216 then
			Allocate(4) -- inferred equivalent call
			WriteU8(7) -- inferred equivalent call
			WriteU24(value) -- inferred equivalent call
		elseif value < 4294967296 then
			Allocate(5) -- inferred equivalent call
			WriteU8(8) -- inferred equivalent call
			WriteU32(value) -- inferred equivalent call
		else
			Allocate(9) -- inferred equivalent call
			WriteU8(10) -- inferred equivalent call
			WriteF64(value) -- inferred equivalent call
		end
	elseif value > -1048576 and value < 1048576 then
		Allocate(5) -- inferred equivalent call
		WriteU8(9) -- inferred equivalent call
		WriteF32(value) -- inferred equivalent call
	else
		Allocate(9) -- inferred equivalent call
		WriteU8(10) -- inferred equivalent call
		WriteF64(value) -- inferred equivalent call
	end
end

v3[11] = function()
	return ReadString(ReadU8()) -- inferred equivalent call
end
function v4.string(list: string)
	local count = #list
	Allocate(count + 2) -- inferred equivalent call
	WriteU8(11) -- inferred equivalent call
	WriteU8(count) -- inferred equivalent call
	WriteString(list) -- inferred equivalent call
end

v3[12] = function()
	return ReadBuffer(ReadU8()) -- inferred equivalent call
end
function v4.buffer(buf: buffer)
	local v12 = buffer.len(buf)
	Allocate(2 + v12) -- inferred equivalent call
	WriteU8(12) -- inferred equivalent call
	WriteU8(v12) -- inferred equivalent call
	WriteBuffer(buf) -- inferred equivalent call
end

v3[13] = function()
	return ReadInstance() -- inferred equivalent call
end
function v4.Instance(p)
	Allocate(1) -- inferred equivalent call
	WriteU8(13) -- inferred equivalent call
	WriteInstance(p) -- inferred equivalent call
end

v3[14] = function(): boolean
	return ReadU8() == 1 -- inferred equivalent call
end
function v4.boolean(flag: boolean)
	Allocate(2) -- inferred equivalent call
	WriteU8(14) -- inferred equivalent call
	buffer.writeu8(v2, bufferOffset, flag and 1 or 0)
	bufferOffset += 1
end

v3[15] = function()
	return NumberRange.new(ReadF32(), ReadF32()) -- inferred equivalent call
end
function v4.NumberRange(range: NumberRange)
	Allocate(9) -- inferred equivalent call
	WriteU8(15) -- inferred equivalent call
	WriteF32(range.Min) -- inferred equivalent call
	WriteF32(range.Max) -- inferred equivalent call
end

v3[16] = function()
	return BrickColor.new(ReadU16()) -- inferred equivalent call
end
function v4.BrickColor(p)
	Allocate(3) -- inferred equivalent call
	WriteU8(16) -- inferred equivalent call
	WriteU16(p.Number) -- inferred equivalent call
end

v3[17] = function()
	return Color3.fromRGB(ReadU8(), ReadU8(), ReadU8()) -- inferred equivalent call
end
function v4.Color3(color: Color3)
	Allocate(4) -- inferred equivalent call
	WriteU8(17) -- inferred equivalent call
	WriteU8(color.R * 255 + 0.5) -- inferred equivalent call
	WriteU8(color.G * 255 + 0.5) -- inferred equivalent call
	WriteU8(color.B * 255 + 0.5) -- inferred equivalent call
end

v3[18] = function()
	return UDim.new(ReadS16() / 1000, ReadS16()) -- inferred equivalent call
end
function v4.UDim(udim: UDim)
	Allocate(5) -- inferred equivalent call
	WriteU8(18) -- inferred equivalent call
	WriteS16(udim.Scale * 1000) -- inferred equivalent call
	WriteS16(udim.Offset) -- inferred equivalent call
end

v3[19] = function()
	local v12 = ReadS16() / 1000 -- inferred equivalent call
	local readS16 = ReadS16() -- inferred equivalent call
	return UDim2.new(v12, readS16, ReadS16() / 1000, ReadS16()) -- inferred equivalent call
end
function v4.UDim2(udim: UDim2)
	Allocate(9) -- inferred equivalent call
	WriteU8(19) -- inferred equivalent call
	WriteS16(udim.X.Scale * 1000) -- inferred equivalent call
	WriteS16(udim.X.Offset) -- inferred equivalent call
	WriteS16(udim.Y.Scale * 1000) -- inferred equivalent call
	WriteS16(udim.Y.Offset) -- inferred equivalent call
end

v3[20] = function()
	return Rect.new(ReadF32(), ReadF32(), ReadF32(), ReadF32()) -- inferred equivalent call
end
function v4.Rect(rect: Rect)
	Allocate(17) -- inferred equivalent call
	WriteU8(20) -- inferred equivalent call
	WriteF32(rect.Min.X) -- inferred equivalent call
	WriteF32(rect.Min.Y) -- inferred equivalent call
	WriteF32(rect.Max.X) -- inferred equivalent call
	WriteF32(rect.Max.Y) -- inferred equivalent call
end

v3[21] = function()
	return Vector2.new(ReadF32(), ReadF32()) -- inferred equivalent call
end
function v4.Vector2(vector2: Vector2)
	Allocate(9) -- inferred equivalent call
	WriteU8(21) -- inferred equivalent call
	WriteF32(vector2.X) -- inferred equivalent call
	WriteF32(vector2.Y) -- inferred equivalent call
end

v3[22] = function()
	return (Vector3.new(ReadF32(), ReadF32(), ReadF32())) -- inferred equivalent call
end
function v4.Vector3(vector3: Vector3)
	Allocate(13) -- inferred equivalent call
	WriteU8(22) -- inferred equivalent call
	WriteF32(vector3.X) -- inferred equivalent call
	WriteF32(vector3.Y) -- inferred equivalent call
	WriteF32(vector3.Z) -- inferred equivalent call
end

v3[23] = function()
	return CFrame.fromEulerAnglesXYZ(
		ReadU16() / 10430.219195527361, -- inferred equivalent call
		ReadU16() / 10430.219195527361, -- inferred equivalent call
		ReadU16() / 10430.219195527361 -- inferred equivalent call
	) + Vector3.new(ReadF32(), ReadF32(), ReadF32()) -- inferred equivalent call
end

function v4.CFrame(cframe: CFrame)
	local eulerAnglesXYZ, v12, v13 = cframe:ToEulerAnglesXYZ()
	Allocate(19) -- inferred equivalent call
	WriteU8(23) -- inferred equivalent call
	WriteU16(eulerAnglesXYZ * 10430.219195527361 + 0.5) -- inferred equivalent call
	WriteU16(v12 * 10430.219195527361 + 0.5) -- inferred equivalent call
	WriteU16(v13 * 10430.219195527361 + 0.5) -- inferred equivalent call
	WriteF32(cframe.X) -- inferred equivalent call
	WriteF32(cframe.Y) -- inferred equivalent call
	WriteF32(cframe.Z) -- inferred equivalent call
end

v3[24] = function()
	return Region3.new(Vector3.new(ReadF32(), ReadF32(), ReadF32()), (Vector3.new(ReadF32(), ReadF32(), ReadF32()))) -- inferred equivalent call
end

function v4.Region3(instance)
	local halfSize = instance.Size / 2
	local v12 = instance.CFrame.Position - halfSize
	local v13 = instance.CFrame.Position + halfSize
	Allocate(25) -- inferred equivalent call
	WriteU8(24) -- inferred equivalent call
	WriteF32(v12.X) -- inferred equivalent call
	WriteF32(v12.Y) -- inferred equivalent call
	WriteF32(v12.Z) -- inferred equivalent call
	WriteF32(v13.X) -- inferred equivalent call
	WriteF32(v13.Y) -- inferred equivalent call
	WriteF32(v13.Z) -- inferred equivalent call
end

v3[25] = function()
	local readU8 = ReadU8() -- inferred equivalent call
	local v12 = table.create(readU8)

	for _ = 1, readU8 do
		local v13 = ReadU8() / 255 -- inferred equivalent call
		local v14 = ReadU8() / 255 -- inferred equivalent call
		table.insert(v12, NumberSequenceKeypoint.new(v13, v14, ReadU8() / 255)) -- inferred equivalent call
	end

	return NumberSequence.new(v12)
end

function v4.NumberSequence(sequence)
	local count = #sequence.Keypoints
	Allocate(count * 3 + 2) -- inferred equivalent call
	WriteU8(25) -- inferred equivalent call
	WriteU8(count) -- inferred equivalent call

	for _, keypoint in sequence.Keypoints do
		WriteU8(keypoint.Time * 255 + 0.5) -- inferred equivalent call
		WriteU8(keypoint.Value * 255 + 0.5) -- inferred equivalent call
		WriteU8(keypoint.Envelope * 255 + 0.5) -- inferred equivalent call
	end
end

v3[26] = function()
	local readU8 = ReadU8() -- inferred equivalent call
	local v12 = table.create(readU8)

	for _ = 1, readU8 do
		local v13 = ReadU8() / 255 -- inferred equivalent call

		table.insert(v12, ColorSequenceKeypoint.new(v13, Color3.fromRGB(ReadU8(), ReadU8(), ReadU8()))) -- inferred equivalent call
	end

	return ColorSequence.new(v12)
end

function v4.ColorSequence(sequence)
	local count = #sequence.Keypoints
	Allocate(count * 4 + 2) -- inferred equivalent call
	WriteU8(26) -- inferred equivalent call
	WriteU8(count) -- inferred equivalent call

	for _, keypoint in sequence.Keypoints do
		WriteU8(keypoint.Time * 255 + 0.5) -- inferred equivalent call
		WriteU8(keypoint.Value.R * 255 + 0.5) -- inferred equivalent call
		WriteU8(keypoint.Value.G * 255 + 0.5) -- inferred equivalent call
		WriteU8(keypoint.Value.B * 255 + 0.5) -- inferred equivalent call
	end
end

v3[27] = function()
	return Enums[ReadU8()]:FromValue(ReadU16()) -- inferred equivalent call
end

function v4.EnumItem(p)
	Allocate(4) -- inferred equivalent call
	WriteU8(27) -- inferred equivalent call
	WriteU8(v8[p.EnumType]) -- inferred equivalent call
	WriteU16(p.Value) -- inferred equivalent call
end

v3[28] = function()
	local result = {}

	while true do
		local readU8 = ReadU8() -- inferred equivalent call

		if readU8 == 0 then
			return result
		end

		local v12 = v3[readU8]()
		result[v12] = v3[ReadU8()]() -- inferred equivalent call
	end
end
function v4.table(items)
	Allocate(1) -- inferred equivalent call
	WriteU8(28) -- inferred equivalent call

	for k, item in items do
		v4[typeof(k)](k)
		v4[typeof(item)](item)
	end

	Allocate(1) -- inferred equivalent call
	WriteU8(0) -- inferred equivalent call
end

local Types = {}

function Types.Import(data)
	v = data
	v2 = data.Buffer
	bufferLength = data.BufferLength
	bufferOffset = data.BufferOffset
	instances = data.Instances
	instancesOffset = data.InstancesOffset
end

function Types.Export()
	v.BufferLength = bufferLength
	v.BufferOffset = bufferOffset
	v.InstancesOffset = instancesOffset
	return v
end

function Types.Truncate()
	local buf = buffer.create(bufferOffset)
	buffer.copy(buf, 0, v2, 0, bufferOffset)

	if instancesOffset == 0 then
		return buf
	end

	return buf, instances
end

function Types.Ended(): boolean
	return bufferLength <= bufferOffset
end

Types.Types = types
Types.Reads = reads
Types.Writes = writes
return Types