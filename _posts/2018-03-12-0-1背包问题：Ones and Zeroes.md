---
layout: post
title: 0-1背包问题：Ones and Zeroes
tags:
  - 算法与数据结构
---

[问题描述](https://leetcode.com/problems/ones-and-zeroes/description/)  
输入一组字符串Array，其中的每个字符串中只可能出现’0’和’1’两种字符；给定两个整数m和n。现在从这组字符串中选取一些字符串，求在保证所选字符串中’0’的个数之和不超过m、’1’的个数之和不超过n的前提下，能够选取到的字符串的最大个数。例如：

Input: Array = {"10", "0001", "111001", "1", "0"}, m = 5, n = 3  
Output: 4  
Explanation: This are totally 4 strings can be formed by the using of 5 0s and 3 1s, which are “10,”0001”,”1”,”0”.

Input: Array = {"10", "0", "1"}, m = 1, n = 1  
Output: 2  
Explanation: You could form "10", but then you'd have nothing left. Better form "0" and "1".

---

### 一、Brute Force
找出Array中包含字符串个数分别为1, 2, 3…, Array.length – 1, Array.length的所有可能组合；然后判断各个组合是否满足m和n分别关于’0’和’1’的约束；满足条件的组合中包含最多字符串的组合的长度即为所求。


### 二、回溯算法
在Brute Force的基础上稍加改进，避免Brute Force中判断是否满足条件时的重复计算问题。例如，在判断组合{A}和{A, another_string}是否满足条件时，Brute Force分别对这两个组合进行判断，从而重复了对{A}的判断；回溯算法则可以利用{A}的处理结果，进一步判断{A, another_string}。代码如下：
```java
public int findMaxForm(String[] strs, int m, int n) {  
    if(strs.length == 0) {  
        return 0;  
    }  
      
    int[][] nums = new int[2][strs.length];  
    for(int i = 0; i < strs.length; i++) {  
        for(char ch : strs[i].toCharArray()) {  
            if(ch == '0') {  
                nums[0][i]++;  
            }  
        }  
        nums[1][i] = strs[i].length() - nums[0][i];  
    }  
      
    int[] state = new int[4];  
    findMaxForm(nums, m, n, state, 0);  
      
    return state[3];  
}  
  
private void findMaxForm(int[][] nums, int m, int n,   
    int[] state, int pos) {  
    if(pos == nums[0].length) {  
        state[3] = Math.max(state[3], state[2]);  
        return;  
    }  
      
    for(int i = pos; i < nums[0].length; i++) {  
        if(nums[0][i] + state[0] <= m &&  
            nums[1][i] + state[1] <= n) {  
            state[0] += nums[0][i];  
            state[1] += nums[1][i];  
            state[2]++;  
            findMaxForm(nums, m, n, state, i + 1);  
            state[0] -= nums[0][i];  
            state[1] -= nums[1][i];  
            state[2]--;  
        } else {  
            state[3] = Math.max(state[3], state[2]);  
        }  
    }  
}  
```


### 三、典型的0-1背包问题：DP解法
上述解法时间复杂度仍然比较大。其实该问题是一个典型的0-1背包问题，DP是该问题的最佳解法。

定义一个m*n的二维整型数组dp，元素(i, j)用于记录在保证所选字符串中’0’的个数之和不超过i、’1’的个数之和不超过j的前提下能够选取到的字符串的最大个数；在遍历输入字符串数组Array过程中，对每个字符串都更新一遍整个dp的状态；最终，dp[m][n]即为题目所求。代码如下：
```java
public int findMaxForm(String[] strs, int m, int n) {  
    int[][] dp = new int[m + 1][n + 1];  
    for (String s : strs) {  
        int[] count = count(s);  
        for (int i = m; i >= count[0]; i--)  
            for (int j = n; j >= count[1]; j--)  
                dp[i][j] = Math.max(1 + dp[i - count[0]][j - count[1]], dp[i][j]);  
    }  
    return dp[m][n];  
}  
  
public int[] count(String str) {  
    int[] res = new int[2];  
    for (int i = 0; i < str.length(); i++)  
        res[str.charAt(i) - '0']++;  
    return res;  
}  
```
以下为[维基百科](https://zh.wikipedia.org/zh-hans/%E8%83%8C%E5%8C%85%E9%97%AE%E9%A2%98)对于背包问题的定义：  
- 背包问题： 给定一组物品，每种物品都有自己的重量和价格，在限定的总重量内，我们如何选择，才能使得物品的总价格最高。问题的名称来源于如何选择最合适的物品放置于给定背包中；
- 0-1背包问题： 限定每种物品只能选择0个或1个；
- 有界背包问题： 限定物品j最多只能选择bj个；
- 无界背包问题： 不限定每种物品的数量。
利用动态规划，背包问题存在一个伪多项式时间算法。各类复杂的背包问题总可以变换为简单的0-1背包问题进行求解。

---

**总结**：DP解法的难点之一是构造状态方程，包括以什么作为状态、如何更新状态等问题

--- 

参考：  
[c++ DP solution with comments](https://leetcode.com/problems/ones-and-zeroes/discuss/95814/c++-DP-solution-with-comments)  
[0-1 knapsack detailed explanation.](https://leetcode.com/problems/ones-and-zeroes/discuss/95807/0-1-knapsack-detailed-explanation.)