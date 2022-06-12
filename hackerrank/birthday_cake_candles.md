```go

/*
 * Complete the 'birthdayCakeCandles' function below.
 *
 * The function is expected to return an INTEGER.
 * The function accepts INTEGER_ARRAY candles as parameter.
 */

func birthdayCakeCandles(candles []int32) int32 {
    dict:= make(map[int32]int32)
    for _, num := range candles {
        dict[num] = dict[num]+1
    }

    sorted := make([]int32, 0, len(dict))
    for k := range dict {
        sorted = append(sorted, k)
    }
    
    sort.Slice(sorted, func(i, j int) bool {
        return dict[sorted[i]] > dict[sorted[j]]
    })
    return dict[sorted[0]]
}

```
