import ('svarog', 'svarog.presentation')

Glossary = {}
Glossary.Meta = {}

function LoadPresentation(name)
    dofile("scripts\\presentation\\" .. name .. ".lua")
end