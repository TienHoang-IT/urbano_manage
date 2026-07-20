import os
import re

def fix_colors():
    base_dir = r'd:\Source\Urbano\urbano_manage\lib'
    for root, dirs, files in os.walk(base_dir):
        for file in files:
            if file.endswith('.dart'):
                filepath = os.path.join(root, file)
                with open(filepath, 'r', encoding='utf-8') as f:
                    content = f.read()
                
                new_content = content
                new_content = re.sub(r'Colors\.white70\b', 'AppColors.textPrimary70', new_content)
                new_content = re.sub(r'Colors\.white\b', 'AppColors.textPrimary', new_content)
                
                if new_content != content:
                    with open(filepath, 'w', encoding='utf-8') as f:
                        f.write(new_content)
                    print(f"Updated {filepath}")

if __name__ == '__main__':
    fix_colors()
