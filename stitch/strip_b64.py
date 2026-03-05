import sys
import re

def strip_b64(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Replace long base64 strings with a placeholder
    content = re.sub(r'data:image/[a-zA-Z0-9+.-]+;base64,[A-Za-z0-9+/=]{100,}', 'data:image/...;base64,...', content)
    
    with open(filepath + '.stripped.html', 'w', encoding='utf-8') as f:
        f.write(content)
    
if __name__ == "__main__":
    for arg in sys.argv[1:]:
        strip_b64(arg)
