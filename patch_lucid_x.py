# -*- coding: utf-8 -*-
import zipfile, plistlib, os, shutil

def patch_ipa():
    input_ipa = 'BaseX.ipa'
    if not os.path.exists(input_ipa):
        input_ipa = 'base-x.ipa'
    output_ipa = 'BaseX-branded.ipa'
    
    print(f"Opening {input_ipa}...")
    
    with open('Localizable_pt.strings', 'rb') as f:
        pt_strings = f.read()
    with open('Localizable_en.strings', 'rb') as f:
        en_strings = f.read()
        
    with zipfile.ZipFile(input_ipa, 'r') as zin, zipfile.ZipFile(output_ipa, 'w', compression=zipfile.ZIP_DEFLATED) as zout:
        for item in zin.infolist():
            filename = item.filename
            
            # 1. Update Info.plist
            if filename == 'Payload/Twitter.app/Info.plist':
                data = zin.read(filename)
                pl = plistlib.loads(data)
                pl['CFBundleDisplayName'] = 'Lucid X'
                pl['CFBundleName'] = 'Lucid X'
                new_data = plistlib.dumps(pl, fmt=plistlib.FMT_XML)
                zout.writestr(item, new_data)
                print("Patched Payload/Twitter.app/Info.plist -> DisplayName: Lucid X")
                
            # 2. Update English strings with Lucid branding
            elif filename == 'Payload/Twitter.app/BHTwitter.bundle/en.lproj/Localizable.strings':
                zout.writestr(item, en_strings)
                print("Replaced BHTwitter.bundle/en.lproj/Localizable.strings")
                
            else:
                # Copy existing entry
                zout.writestr(item, zin.read(filename))
                
        # 3. Add Portuguese translations (pt-BR and pt)
        zout.writestr('Payload/Twitter.app/BHTwitter.bundle/pt-BR.lproj/Localizable.strings', pt_strings)
        print("Added Payload/Twitter.app/BHTwitter.bundle/pt-BR.lproj/Localizable.strings")
        
        zout.writestr('Payload/Twitter.app/BHTwitter.bundle/pt.lproj/Localizable.strings', pt_strings)
        print("Added Payload/Twitter.app/BHTwitter.bundle/pt.lproj/Localizable.strings")

    print(f"Successfully generated {output_ipa}!")

if __name__ == '__main__':
    patch_ipa()
