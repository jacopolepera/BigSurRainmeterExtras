function Initialize()
	-- Niente da inizializzare
end

function Update()
	-- Legge il testo grezzo scaricato da WebParser
	local rawData = SKIN:GetMeasure('MeasureRaw'):GetStringValue()
	
	-- Se è vuoto, fermati
	if rawData == "" then return end

	-- Pattern per trovare ogni blocco <entry>...</entry>
	-- Lua usa % al posto di \ per l'escape. (.-) significa "prendi il minimo possibile"
	local entryPattern = "<entry.-</entry>"
	
	local count = 0
	
	-- Ciclo su ogni entry trovata nel testo
	for entry in string.gmatch(rawData, entryPattern) do
		count = count + 1
		if count > 15 then break end -- Ci fermiamo a 15 mail

		-- Estraiamo i dati usando pattern che ignorano gli attributi (es: <title type='html'>)
		-- Cerchiamo il contenuto tra > e </
		local title = entry:match("<title.->(.-)</title>") or "No Title"
		local summary = entry:match("<summary.->(.-)</summary>") or "No Content"
		
		-- Per l'autore, cerchiamo name dentro author.
		-- Cerchiamo prima il blocco author, poi name al suo interno
		local authorBlock = entry:match("<author.->(.-)</author>") or ""
		local sender = authorBlock:match("<name.->(.-)</name>") or "Unknown"

		-- PULIZIA (Opzionale ma consigliata per Gmail)
		-- Rimuove eventuali tag HTML residui e spazi eccessivi
		title = CleanString(title)
		summary = CleanString(summary)
		sender = CleanString(sender)

		-- Inviamo le variabili a Rainmeter
		-- Creiamo variabili tipo Title1, Body1, Sender1, Title2...
		SKIN:Bang('!SetVariable', 'Title'..count, title)
		SKIN:Bang('!SetVariable', 'Body'..count, summary)
		SKIN:Bang('!SetVariable', 'Sender'..count, sender)
	end
    
    -- Se abbiamo trovato meno di 15 mail, svuotiamo le variabili rimanenti per non vedere dati vecchi
    if count < 15 then
        for i = count + 1, 15 do
            SKIN:Bang('!SetVariable', 'Title'..i, "")
            SKIN:Bang('!SetVariable', 'Body'..i, "")
            SKIN:Bang('!SetVariable', 'Sender'..i, "")
        end
    end

	return "Parsed " .. count .. " emails"
end

function CleanString(str)
	if not str then return "" end
	-- Rimuove tag HTML <br>, <b> ecc
	str = string.gsub(str, "<.->", "")
	-- Decodifica base entità HTML che WebParser potrebbe aver saltato (opzionale)
	str = string.gsub(str, "&lt;", "<")
	str = string.gsub(str, "&gt;", ">")
	str = string.gsub(str, "&amp;", "&")
    str = string.gsub(str, "&quot;", '"')
    str = string.gsub(str, "&#39;", "'")
	return str
end