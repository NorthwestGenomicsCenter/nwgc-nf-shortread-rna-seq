public class Utils {
    public static Object formatParamsForInclusion(label, value) {
        if(value != null && !value.isEmpty()) {
            return [(label): value]
        }
        return
    }
}