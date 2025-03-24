// 搜索前五个包（秘术牌或塔罗牌）中每个都包含 The Soul 的种子
#include "lib/immolate.cl"
long filter(instance* inst) {
    int ante = 1;
    int soul_count = 0;
    
    // 检查前五个包
    for (int i = 0; i < 5; i++) {
        item pack_item = next_pack(inst, ante);
        pack pack_details = pack_info(pack_item);
        
        item cards[5];  // 假设最大牌组大小为5
        bool found_soul = false;
        
        // 检查秘术牌组和塔罗牌组
        if (pack_details.type == Spectral_Pack) {
            spectral_pack(cards, pack_details.size, inst, ante);
        } else if (pack_details.type == Arcana_Pack) {
            arcana_pack(cards, pack_details.size, inst, ante);
        } else {
            continue;  // 跳过其他类型的包
        }
        
        // 检查当前包中是否有 The Soul
        for (int j = 0; j < pack_details.size; j++) {
            if (cards[j] == The_Soul) {
                soul_count++;
                found_soul = true;
                break;
            }
        }
        
        // 如果当前包没有找到 The Soul，直接返回已找到的数量
        if (!found_soul) {
            return soul_count;
        }
    }
    
    return soul_count;
}