function kiro9fix --description 'Import fixed Kiro data and restart 9router'
    python3 /home/rayin/infra/data/9router/import_kiro_fixed.py
    and docker restart 9router
end
