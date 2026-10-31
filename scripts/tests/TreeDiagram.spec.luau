-- SPDX-License-Identifier: MIT
-- SPDX-FileCopyrightText: 2026 Hawakiki and EnterpriseEdition contributors
--!strict

local Assert = require("./Assert")
local TreeDiagram = require("../lib/TreeDiagram")

local cases: { Assert.Case } = {}
local function case(name: string, run: () -> ())
	table.insert(cases, { name = name, run = run })
end

local OPTIONS: TreeDiagram.Options = { header = { "SPDX-License-Identifier: MIT" }, title = "A tree" }

local function node(id: string, parent: string?, lines: { string }?, style: TreeDiagram.Style?): TreeDiagram.Node
	return { id = id, parent = parent, lines = lines or { id }, style = style or "solid" }
end

local FAMILY = {
	node("root"),
	node("a", "root"),
	node("a1", "a"),
	node("a2", "a"),
	node("b", "root"),
}

-- The y of the first <rect class=...> drawn for a node, found by the text that follows it.
local function topOf(svg: string, label: string): number
	local y = string.match(svg, 'y="(%d+)"[^\n]*\n<text class="first" x="%d+" y="%d+">' .. label .. "</text>")
	assert(y, "no box for " .. label)
	return tonumber(y) :: number
end

local function widthOf(svg: string, label: string): number
	local width =
		string.match(svg, 'width="(%d+)" height="%d+" rx="%d+"/>\n<text class="first" x="%d+" y="%d+">' .. label)
	assert(width, "no box for " .. label)
	return tonumber(width) :: number
end

case("the same tree gives the same bytes", function()
	Assert.equal(TreeDiagram.svg(FAMILY, OPTIONS), TreeDiagram.svg(FAMILY, OPTIONS), "svg")
	Assert.equal(
		TreeDiagram.text(FAMILY, function(n)
			return n.id
		end),
		TreeDiagram.text(FAMILY, function(n)
			return n.id
		end),
		"text"
	)
end)

case("the header comes first, and the document is a single svg", function()
	local svg = TreeDiagram.svg(FAMILY, OPTIONS)
	Assert.equal(string.sub(svg, 1, 40), "<!-- SPDX-License-Identifier: MIT -->\n<s", "header first")
	Assert.equal(select(2, string.gsub(svg, "<svg ", "")), 1, "one svg element")
	Assert.equal(string.sub(svg, -7), "</svg>\n", "ends with the element and a newline")
end)

case("a parent sits in the middle of its children, and a leaf below the one before", function()
	local svg = TreeDiagram.svg(FAMILY, OPTIONS)
	local a1, a2, b = topOf(svg, "a1"), topOf(svg, "a2"), topOf(svg, "b")
	Assert.truthy(a1 < a2 and a2 < b, "leaves take rows in order")
	Assert.equal(topOf(svg, "a"), (a1 + a2) / 2, "a between its children")
	Assert.equal(topOf(svg, "root"), (topOf(svg, "a") + b) / 2, "root between its first and last child")
end)

case("there is one edge for every node with a parent", function()
	local svg = TreeDiagram.svg(FAMILY, OPTIONS)
	Assert.equal(select(2, string.gsub(svg, '<path class="edge"', "")), 4, "edges")
end)

case("a wide character counts twice in the width of a box", function()
	local narrow = TreeDiagram.svg({ node("n", nil, { "abcd" }) }, OPTIONS)
	local wide = TreeDiagram.svg({ node("w", nil, { "가나다라" }) }, OPTIONS)
	Assert.truthy(widthOf(wide, "가나다라") > widthOf(narrow, "abcd"), "Hangul is wider than as many ASCII letters")
end)

case("text is escaped, and styles become classes", function()
	local svg = TreeDiagram.svg({ node("x", nil, { "A & <B>" }, "dashed"), node("y", "x", { "y" }, "bold") }, OPTIONS)
	Assert.contains(svg, "A &amp; &lt;B&gt;", "escaped")
	Assert.contains(svg, 'class="card dashed"', "dashed")
	Assert.contains(svg, 'class="card bold"', "bold")
end)

case("the text version draws the same tree", function()
	local text = TreeDiagram.text(FAMILY, function(n)
		return n.id
	end)
	Assert.equal(text, "root\n├─ a\n│  ├─ a1\n│  └─ a2\n└─ b\n", "tree")
end)

case("a node whose parent is absent is drawn as a root", function()
	local text = TreeDiagram.text({ node("orphan", "missing") }, function(n)
		return n.id
	end)
	Assert.equal(text, "orphan\n", "orphan")
end)

return { name = "TreeDiagram", cases = cases } :: Assert.Suite
