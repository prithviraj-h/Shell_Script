#!/bin/bash

# === Ask for Inputs ===
echo "Enter Component Name (INGESTOR/JOINER/WRANGLER/VALIDATOR):"
read component

echo "Enter New Scale (MID/HIGH/LOW):"
read scale

echo "Enter New View (Auction/Bid):"
read view

echo "Enter New Count (0-9):"
read count

# === Validate Inputs ===
if [[ "$component" != "INGESTOR" && "$component" != "JOINER" && "$component" != "WRANGLER" && "$component" != "VALIDATOR" ]]; then
    echo "Invalid Component Name."
    exit 1
fi

if [[ "$scale" != "MID" && "$scale" != "HIGH" && "$scale" != "LOW" ]]; then
    echo "Invalid Scale."
    exit 1
fi

if [[ "$view" != "Auction" && "$view" != "Bid" ]]; then
    echo "Invalid View."
    exit 1
fi

if ! [[ "$count" =~ ^[0-9]$ ]]; then
    echo "Invalid Count (should be single digit 0–9)."
    exit 1
fi

# === Convert View ===
if [[ "$view" == "Auction" ]]; then
    view_value="vdopiasample"
else
    view_value="vdopiasample-bid"
fi

# === Initialize flags and temp file ===
updated=0
> sig.conf.tmp

# === Read and update file ===
while IFS=";" read -r file_view file_scale file_component file_etl file_count
do
    # Trim spaces
    file_component=$(echo "$file_component" | xargs)
    file_etl=$(echo "$file_etl" | xargs)

    if [[ "$updated" -eq 0 && "$file_component" == "$component" ]]; then
        # Replace line for matching component
        echo "$view_value ; $scale ; $component ; ETL ; vdopia-etl=$count" >> sig.conf.tmp
        updated=1
    else
        # Keep original line
        echo "$file_view ; $file_scale ; $file_component ; $file_etl ; $file_count" >> sig.conf.tmp
    fi

done < sig.conf

# === Finalize ===
if [[ "$updated" -eq 1 ]]; then
    mv sig.conf.tmp sig.conf
    echo "sig.conf updated successfully for component: $component"
else
    rm sig.conf.tmp
    echo "No matching component found. No changes made."
fi





























































