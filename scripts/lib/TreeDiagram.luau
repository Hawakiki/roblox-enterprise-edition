-- SPDX-License-Identifier: MIT
-- SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
--!strict
--[[
	Draws a tree, as SVG and as text. The SVG is laid out from left to right: each depth in a column, each leaf in
	a row of its own, and each parent level with the middle of its children. Boxes are white cards sized by the
	display width of their lines, so that a wide character counts twice, as in the commit messages (EE-STD-0007).
	The same tree always gives the same bytes, so that a check can compare the output with what is committed.
	나무를 SVG 와 텍스트로 그린다. SVG 는 왼쪽에서 오른쪽으로 배치한다. 깊이마다 열 하나, 잎마다 행 하나를 쓰고,
	부모는 자식들의 가운데에 둔다. 상자는 줄의 표시 폭에 맞춘 흰 카드이며, 커밋 메시지(EE-STD-0007)처럼 넓은 문자는
	두 칸으로 센다. 같은 나무는 언제나 같은 바이트가 되므로, 검사가 생성 결과를 커밋된 것과 비교할 수 있다.
]]

local Text = require("./Text")

export type Style = "solid" | "dashed" | "bold"

export type Node = {
	id: string,
	-- The first line is drawn in bold.
	lines: { string },
	-- The id of the parent, or nil for a root.
	parent: string?,
	style: Style,
}

export type Options = {
	-- Comment lines written before the root element, such as the license header.
	header: { string },
	title: string,
}

local FONT_SIZE = 12
local CHARACTER_WIDTH = 7.5
local LINE_HEIGHT = 16
local PADDING_X = 10
local PADDING_Y = 8
local COLUMN_GAP = 40
local ROW_GAP = 12
local MARGIN = 16
local CORNER = 6

local STYLE = table.concat({
	"text{font-family:ui-monospace,SFMono-Regular,Menlo,Consolas,'Noto Sans Mono CJK KR','Malgun Gothic',monospace;",
	"font-size:" .. FONT_SIZE .. "px;fill:#1f2328}",
	".first{font-weight:bold}",
	".card{fill:#ffffff;stroke:#57606a;stroke-width:1}",
	".dashed{stroke-dasharray:5 4}",
	".bold{stroke-width:2.5}",
	".edge{fill:none;stroke:#8c959f;stroke-width:1.2}",
})

type Placed = {
	node: Node,
	depth: number,
	row: number,
	children: { string },
}

local TreeDiagram = {}

local function escape(text: string): string
	return (
		string.gsub(text, "[&<>\"']", {
			["&"] = "&amp;",
			["<"] = "&lt;",
			[">"] = "&gt;",
			['"'] = "&quot;",
			["'"] = "&apos;",
		})
	)
end

local function round(value: number): string
	return string.format("%d", math.floor(value + 0.5))
end

-- The children of every node in input order, and the roots: nodes without a parent, or whose parent is absent.
local function structure(nodes: { Node }): ({ [string]: { string } }, { string }, { [string]: Node })
	local byId: { [string]: Node } = {}
	for _, node in nodes do
		byId[node.id] = node
	end
	local children: { [string]: { string } } = {}
	local roots: { string } = {}
	for _, node in nodes do
		children[node.id] = children[node.id] or {}
		local parent = node.parent
		if parent and byId[parent] then
			children[parent] = children[parent] or {}
			table.insert(children[parent], node.id)
		else
			table.insert(roots, node.id)
		end
	end
	return children, roots, byId
end

-- Gives every node a depth and a row: leaves take rows in order, and a parent sits in the middle of its children.
local function place(nodes: { Node }): ({ Placed }, number, number)
	local children, roots, byId = structure(nodes)
	local placed: { Placed } = {}
	local nextRow = 0
	local deepest = 0
	local function visit(id: string, depth: number): number
		local entry: Placed = { node = byId[id], depth = depth, row = 0, children = children[id] }
		table.insert(placed, entry)
		deepest = math.max(deepest, depth)
		if #entry.children == 0 then
			entry.row = nextRow
			nextRow += 1
		else
			local first, last = 0, 0
			for index, child in entry.children do
				local row = visit(child, depth + 1)
				if index == 1 then
					first = row
				end
				last = row
			end
			entry.row = (first + last) / 2
		end
		return entry.row
	end
	for _, root in roots do
		visit(root, 0)
	end
	return placed, nextRow, deepest
end

local function widthOf(lines: { string }): number
	local widest = 0
	for _, line in lines do
		widest = math.max(widest, Text.displayWidth(line))
	end
	return widest * CHARACTER_WIDTH + 2 * PADDING_X
end

-- The tree as SVG.
function TreeDiagram.svg(nodes: { Node }, options: Options): string
	local placed, rows, deepest = place(nodes)
	local lineCount = 1
	local columnWidth: { number } = {}
	for depth = 0, deepest do
		columnWidth[depth + 1] = 0
	end
	for _, entry in placed do
		lineCount = math.max(lineCount, #entry.node.lines)
		columnWidth[entry.depth + 1] = math.max(columnWidth[entry.depth + 1], widthOf(entry.node.lines))
	end
	local boxHeight = 2 * PADDING_Y + lineCount * LINE_HEIGHT
	local columnX: { number } = {}
	local x = MARGIN
	for depth = 0, deepest do
		columnX[depth + 1] = x
		x += columnWidth[depth + 1] + COLUMN_GAP
	end
	local width = x - COLUMN_GAP + MARGIN
	local height = 2 * MARGIN + math.max(rows, 1) * boxHeight + math.max(rows - 1, 0) * ROW_GAP

	local function top(entry: Placed): number
		return MARGIN + entry.row * (boxHeight + ROW_GAP)
	end

	local out: { string } = {}
	for _, line in options.header do
		table.insert(out, "<!-- " .. line .. " -->")
	end
	table.insert(
		out,
		string.format(
			'<svg xmlns="http://www.w3.org/2000/svg" width="%s" height="%s" viewBox="0 0 %s %s" role="img">',
			round(width),
			round(height),
			round(width),
			round(height)
		)
	)
	table.insert(out, "<title>" .. escape(options.title) .. "</title>")
	table.insert(out, "<style>" .. STYLE .. "</style>")
	table.insert(out, string.format('<rect width="%s" height="%s" fill="#ffffff"/>', round(width), round(height)))

	local byId: { [string]: Placed } = {}
	for _, entry in placed do
		byId[entry.node.id] = entry
	end
	for _, entry in placed do
		local parentRight = columnX[entry.depth + 1] + columnWidth[entry.depth + 1]
		local parentMiddle = top(entry) + boxHeight / 2
		for _, childId in entry.children do
			local child = byId[childId]
			local childLeft = columnX[child.depth + 1]
			local bend = parentRight + COLUMN_GAP / 2
			table.insert(
				out,
				string.format(
					'<path class="edge" d="M%s %sH%sV%sH%s"/>',
					round(parentRight),
					round(parentMiddle),
					round(bend),
					round(top(child) + boxHeight / 2),
					round(childLeft)
				)
			)
		end
	end
	for _, entry in placed do
		local left, y = columnX[entry.depth + 1], top(entry)
		local class = if entry.node.style == "solid" then "card" else "card " .. entry.node.style
		table.insert(
			out,
			string.format(
				'<rect class="%s" x="%s" y="%s" width="%s" height="%s" rx="%d"/>',
				class,
				round(left),
				round(y),
				round(columnWidth[entry.depth + 1]),
				round(boxHeight),
				CORNER
			)
		)
		for index, line in entry.node.lines do
			table.insert(
				out,
				string.format(
					'<text%s x="%s" y="%s">%s</text>',
					if index == 1 then ' class="first"' else "",
					round(left + PADDING_X),
					round(y + PADDING_Y + (index - 1) * LINE_HEIGHT + FONT_SIZE),
					escape(line)
				)
			)
		end
	end
	table.insert(out, "</svg>")
	return table.concat(out, "\n") .. "\n"
end

-- The tree as text, one node a line, drawn with box-drawing characters.
function TreeDiagram.text(nodes: { Node }, label: (Node) -> string): string
	local children, roots, byId = structure(nodes)
	local out: { string } = {}
	local function visit(id: string, prefix: string, last: boolean, root: boolean)
		local node = byId[id]
		table.insert(
			out,
			if root then label(node) else prefix .. (if last then "└─ " else "├─ ") .. label(node)
		)
		local below = if root then "" else prefix .. (if last then "   " else "│  ")
		local list = children[id]
		for index, child in list do
			visit(child, below, index == #list, false)
		end
	end
	for _, root in roots do
		visit(root, "", true, true)
	end
	return table.concat(out, "\n") .. "\n"
end

return TreeDiagram
