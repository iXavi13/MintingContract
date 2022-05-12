

using Counters for Counters.Counter;
library Counters {
    struct Counter {
        uint256 _value; // default: 0
    }

    function current(Counter storage counter) internal view returns (uint256) {
        return counter._value;
    }

    function increment(Counter storage counter, uint256 amount) internal {
        unchecked {
            counter._value += amount;
        }
    }

    function decrement(Counter storage counter, uint256 amount) internal {
        unchecked {
            counter._value -= amount;
        }
    }

    function reset(Counter storage counter) internal {
        counter._value = 0;
    }
}