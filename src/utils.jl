# Convert array of particular type to array of Dual
function seed_duals(x::AbstractArray{V},::Type{T},
                    ::ForwardDiff.Chunk{N} = ForwardDiff.Chunk(x)) where {V,T,N}
  seeds = ForwardDiff.construct_seeds(ForwardDiff.Partials{N,V})
  duals = [ForwardDiff.Dual{T}(x[i],seeds[i]) for i in eachindex(x)]
end

# Relu function is used as a constrain for γ's values
relu(x::Real) = max(zero(x), x)

# update method
function update!(opt, ps::Array, ps̅::Array, chunk)
  for p in ps, p̄ in ps̅
    p_value = [element.value for element in p]
    p_value .-= apply!(opt, p_value, p̄)
    new_p = seed_duals(p_value, eltype(p̄), chunk)
    p .= new_p
  end
end

# partition the gradient into sub-arrays for each parameter
function grads(θ̄::Vector{T}, indexes) where T
  ll = length(indexes)
  partition_θ̄ = Array{Array{T, 1}}(undef, ll)
  for i in 1:ll
    partition_θ̄[i] = θ̄[indexes[i]]
  end
  return partition_θ̄
end
