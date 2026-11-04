package trivy

default ignore = false

ignore {
    input.Type == "misconfiguration"
    input.ID == "DS-0026"
}
