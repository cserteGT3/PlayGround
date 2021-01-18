using JSON
using Logging

# msgs = readjson("message_1.json")
function readjson(fname)
	f = read(fname, String)
	fd = JSON.parse(f)
	return fd["messages"]
end

function collectlinks(messages)
	links = String[]
	for i in 1:size(messages, 1)
		msg = messages[i]
		haskey(msg, "content") || continue
		msgc = msg["content"]
		if occursin("spotify.", msgc) || occursin("music.apple", msgc) || occursin("youtube.", msgc)
			if occursin("\n", msgc)
				#@show i
				msgcs = split(msgc, "\n")
				for msgc in msgcs
					occursin(".com", msgc) && push!(links, msgc)
				end
			else
				push!(links, msgc)
			end
		end
	end
	return links
end

function writehtml(links, endfile)
	open(endfile, "w") do io
		println(io, "<!DOCTYPE html>\n<html>\n<body>")
		for l in links
			println(io, """<p><a href="$l">$l</a></p>""")
		end
		println(io, "</body>\n</html>")
	end
	@info "Finished writing $(length(links)) links."
end

# completeproc("message_1.json")
function completeproc(fname)
	readjson(fname) |> collectlinks |> x -> writehtml(x, "links.html")
end
