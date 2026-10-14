-- One demo binary per chapter folder (NN-name)
--   xmake               builds every chapter
--   xmake run NN-name   runs one chapter's demo, e.g. `xmake run 26-prim`

add_rules("mode.debug", "mode.release")
add_rules("plugin.compile_commands.autoupdate", { outputdir = "./" })
set_languages("c++17")

-- A chapter that uses another chapter's code includes it by relative path ("../21-disjoint-sets/DisjointSets.h");
-- if that code has .cpp files, list the folder here so they are compiled into the chapter's binary
local uses = {
    ["25-kruskal"] = { "21-disjoint-sets" },
    ["26-prim"]    = { "21-disjoint-sets", "25-kruskal" },
}

for _, dir in ipairs(os.dirs(path.join(os.scriptdir(), "*"))) do
    local name = path.filename(dir)
    if name:match("^%d%d%-") then
        target(name)
            set_kind("binary")
            add_files(name .. "/*.cpp")
            for _, dep in ipairs(uses[name] or {}) do
                add_files(dep .. "/*.cpp|main.cpp")
            end
        target_end()
    end
end
