// Some important definitions
__constant char SEEDCHARS[] = "123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";
__constant int NUM_CHARS = 35;

// 使用位运算优化字符转数字函数
int s_char_num(char c){
    return c - (49 + ((c > 57) << 3) - ((c > 57) << 1) - (c > 57));  // 49 + (c>57)*7 的位运算优化
}

typedef struct Seed {
    ulong8 data;
    int len;
} seed;

seed s_new_empty() {
    seed seed;
    seed.data = 0; //fills with zeros
    seed.len = 0;
    return seed;
}
seed s_new(__constant char* str_seed, int seed_size) {
    seed seed;
    for (int i = 0; i < seed_size; i++) {
        for (char j = 0; j < NUM_CHARS; j++) {
            if (SEEDCHARS[j] == str_seed[i]) {
                seed.data[i] = j;
            }
        }
    }
    seed.len = seed_size;
    return seed;
}

seed s_new_c8(char8 str_seed) {
    seed seed;
    for (int i = 0; i < 8; i++) {
        if (str_seed[i] == '\0') {
            seed.len = i;
            return seed;
        }
        seed.data[i] = s_char_num(str_seed[i]);
    }
    seed.len = 8;
    return seed;
}

char s_char_at(seed* s, int c) {
    return SEEDCHARS[s->data[c]];
}
long s_tell(seed* s) {
    long loc = 0;
    long mult = 0;
    for (int i = 0; i < s->len; i++) {
        loc += s->data[i]*mult;
        mult *= NUM_CHARS;
    }
    return loc;
}
text s_to_string(seed* s) {
    text str;
    for (int i = 0; i < s->len; i++) {
        str.str[i]=s_char_at(s, i);
    }
    set_text_length(&str, s->len);
    return str;
}

void s_print(seed* s) {
    text s_str = s_to_string(s);
    printf("%s",s_str.str);
}
void s_print_rank(seed* s, long rank) {
    text s_str = s_to_string(s);
    printf("%s (%li)\n",s_str.str,rank);
}
void s_next(seed* s) {
    s->data[s->len-1] = (s->data[s->len-1]+1)%NUM_CHARS;
    int carry = s->data[s->len-1] == 0;
    for (int i = s->len - 2; (i >= 0 && carry); i--) {
        s->data[i] = (s->data[i]+carry)%NUM_CHARS;
        carry &= (s->data[i] == 0);  // 使用位与运算
    }
    s->len += carry;
}

void s_skip(seed* s, long n) {
    int carry = 0;
    int i = s->len - 1;
    int j = 0;
    ulong8 data = 0;
    while(n > 0 || carry || j < s->len){
        // 使用位运算优化条件判断
        int i_valid = -(i >= 0);  // 如果i>=0，则为全1（-1），否则为0
        int sum = carry + (n % NUM_CHARS);
        sum += (s->data[i & i_valid] & i_valid) + (~i_valid & -1);  // 位运算优化的条件选择
        
        data[j] = sum % NUM_CHARS;
        carry = sum >= NUM_CHARS;
        n /= NUM_CHARS;
        i--;
        j++;
    }
    // 使用位运算优化条件更新
    int len_update = -(s->len <= j);  // 如果s->len<=j，则为全1，否则为0
    s->len += (j - s->len) & len_update;
    
    for(int x = 0; x < s->len; x++){
        s->data[s->len-1-x] = data[x];
    }
}