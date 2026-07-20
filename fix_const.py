import re
import os

def fix_const_errors():
    analyze_file = 'analyze.txt'
    if not os.path.exists(analyze_file):
        print(f"Error: {analyze_file} not found")
        return

    pattern = re.compile(r'error - Invalid constant value - (.*?):(\d+):\d+ - invalid_constant')
    
    # Track files and lines to modify
    modifications = {}
    
    with open(analyze_file, 'r', encoding='utf-16') as f:
        for line in f:
            match = pattern.search(line)
            if match:
                filepath = match.group(1).strip()
                # Handle Windows paths if necessary
                filepath = filepath.replace('\\', '/')
                line_num = int(match.group(2)) - 1 # 0-indexed
                
                if filepath not in modifications:
                    modifications[filepath] = set()
                modifications[filepath].add(line_num)
                
    count = 0
    for filepath, lines in modifications.items():
        if not os.path.exists(filepath):
            print(f"File not found: {filepath}")
            continue
            
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.readlines()
            
        modified = False
        for line_num in sorted(lines):
            if line_num < len(content):
                original_line = content[line_num]
                # Replace 'const ' with ''
                # We need to be careful to only replace the word const
                new_line = re.sub(r'\bconst\s+', '', original_line)
                if new_line != original_line:
                    content[line_num] = new_line
                    modified = True
                    count += 1
                else:
                    # sometimes the const is on the previous line or it's implicitly const due to parent
                    # Let's try searching backwards a bit if const is not on this line
                    for search_line in range(line_num, max(-1, line_num - 15), -1):
                        search_orig = content[search_line]
                        new_search = re.sub(r'\bconst\s+', '', search_orig)
                        if new_search != search_orig:
                            content[search_line] = new_search
                            modified = True
                            count += 1
                            break

        if modified:
            with open(filepath, 'w', encoding='utf-8') as f:
                f.writelines(content)
                
    print(f"Fixed {count} const instances across {len(modifications)} files.")

if __name__ == '__main__':
    fix_const_errors()
