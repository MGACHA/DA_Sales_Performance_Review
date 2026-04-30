from pathlib import Path

import pandas as pd


WORKBOOK = Path(__file__).parent / "DA Interview Task.xlsx"
OUTPUT_DIR = Path(__file__).parent / "csv_export"


def main() -> None:
    OUTPUT_DIR.mkdir(exist_ok=True)
    workbook = pd.ExcelFile(WORKBOOK)

    print(f"Workbook: {WORKBOOK}")
    print(f"Output folder: {OUTPUT_DIR}")

    for sheet_name in workbook.sheet_names:
        dataframe = pd.read_excel(WORKBOOK, sheet_name=sheet_name)
        output_path = OUTPUT_DIR / f"{sheet_name}.csv"
        dataframe.to_csv(output_path, index=False)
        print(f"Exported {sheet_name} -> {output_path.name} ({len(dataframe)} rows)")


if __name__ == "__main__":
    main()