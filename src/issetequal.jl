# TODO: Should this also return false (or error) if `a` or `b` don't have unique elements?
issetequal(a,b) = a ⊆ b && b ⊆ a
