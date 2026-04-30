import pandas as pd
from pathlib import Path


def show_duplicates_in_file(file_path: Path):
    print(f"\n--- {file_path.name} ---")
    df = pd.read_csv(file_path)

    # Find duplicates using all columns
    duplicates = df[df.duplicated(keep=False)]
    print(f"Number of duplicate rows: {len(duplicates)}")

    if not duplicates.empty:
        print("Sample duplicates:")
        print(duplicates.head(10).to_string(index=False))
    else:
        print("No duplicates found.")

    return duplicates


def show_duplicates_in_folder(folder_path="csv_export"):
    folder = Path(folder_path)
    csv_files = sorted(folder.glob("*.csv"))

    if not csv_files:
        print(f"No CSV files found in: {folder.resolve()}")
        return {}

    all_duplicates = {}
    print(f"Checking duplicates in folder: {folder.resolve()}")

    for file_path in csv_files:
        all_duplicates[file_path.name] = show_duplicates_in_file(file_path)

    return all_duplicates


if __name__ == "__main__":
    show_duplicates_in_folder("csv_export")