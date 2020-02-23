
random_point(M::Manifold) = random_point(M, Val(:Gaussian))

@doc doc"""
    random_point(M, :Uniform)

return a random point on the [`Circle`](@ref) $\mathbb S^1$ by
picking a random element from $[-\pi,\pi)$ uniformly.
"""
random_point(M::Circle, ::Val{:Uniform}) = sym_rem(rand()*2*π)
random_point(M::Circle) = random_point(M,Val(:Uniform)) # introduce different default

@doc doc"""
    random_point(M[,T=Float64])

generate a random point on the [`Euclidean`](@ref) manifold `M`, where the
optional parameter determines the type of the entries of the
resulting [`RnPoint`](@ref).
"""
random_point(M::Euclidean, T::DataType=Float64) = randn(T, manifold_dimension(M))

@doc doc"""
    random_point(M [,type=:Gaussian, σ=1.0])

return a random point `x` on [`Grassmannian`](@ref) manifold `M` by
generating a random (Gaussian) matrix with standard deviation `σ` in matching
size, which is orthonormal.
"""
function random_point(M::Grassmann{n,k,𝔽}, ::Val{:Gaussian}, σ::Float64=1.0) where {n,k,𝔽}
  	V = σ * randn(𝔽===ℝ ? Float64 : ComplexF64, (n, k))
  	A = qr(V).Q[:,1:k]
    return A
end

random_point(M::ProductManifold, o...) = [ random_point(N, o...) for N in M.manifolds ]

@doc doc"""
    randomMPoint(M::Rotations[, type=:Gaussian, σ=1.0])

return a random point `p` on the manifold `Rotations`
by generating a (Gaussian) random orthogonal matrix with determinant $+1$. Let $QR = A$
be the QR decomposition of a random matrix $A$, then the formula reads $p = QD$
where $D$ is a diagonal matrix with the signs of the diagonal entries of $R$, i.e.
````math
D_{ij}=\begin{cases}
\operatorname{sgn}(R_{ij}) & \text{if} \; i=j \\
0 & \, \text{otherwise.}
\end{cases}$
````
It can happen that the matrix gets -1 as a determinant. In this case, the first
and second columns are swapped.
"""
function random_point(M::Rotations, ::Val{:Gaussian}, σ::Real=1.0)
  if M.dimension==1
    return ones(1,1)
  else
    A=randn(Float64, M.dimension, M.dimension)
    s=diag(sign.(qr(A).R))
    D=Diagonal(s)
    C = qr(A).Q*D
    if det(C)<0
      C[:,[1,2]] = C[:,[2,1]]
    end
    return C
  end
end

@doc doc"""
    randomMPoint(M::SymmetricPositiveDefinite, :Gaussian[, σ=1.0])
gerenate a random symmetric positive definite matrix on the
[`SymmetricPositiveDefinite`](@ref) manifold `M`.
"""
function random_point(M::SymmetricPositiveDefinite{N},::Val{:Gaussian},σ::Float64=1.0) where N
    D = Diagonal( 1 .+ randn(N) ) # random diagonal matrix
    s = qr(σ * randn(N,N)) # random q
    return s.Q * D * transpose(s.Q)
end

@doc doc"""
    random_point(M::Stiefel [,:Gaussian, σ=1.0])

return a random (Gaussian) point `x` on the Stiefel manifold `M` by generating a (Gaussian)
matrix with standard deviation `σ` and return the orthogonalized version, i.e. return ​​the Q
component of the QR decomposition of the random matrix of size $n×k$.
"""
function random_point(M::Stiefel{n,k,𝔽}, ::Val{:Gaussian}, σ::Float64=1.0) where {n,k,𝔽}
    A = σ*randn(𝔽===ℝ ? Float64 : ComplexF64, n, k)
    return Matrix(qr(A).Q)
end

@doc doc"""
    random_point(M::Sphere [,:Gaussian, σ=1.0])
return a random point on the Sphere by projecting a normal distirbuted vector
from within the embedding to the sphere.
"""
function random_point(M::Sphere, ::Val{:Gaussian}, σ::Float64=1.0)
	return project_point(M, σ * randn(manifold_dimension(M)+1))
end

@doc doc"""
    random_tangent(M::Circle, x[, :Gaussian, σ=1.0])

return a random tangent vector from the tangent space of the point `x` on the
[`Circle`](@ref) $\mathbb S^1$ by using a normal distribution with
mean 0 and standard deviation 1.
"""
random_tangent(M::Circle, p, ::Val{:Gaussian}, σ::Real=1.0) = σ*randn()

doc"""
    random_tangent(M,x,:Gaussian[,σ=1.0])

generate a Gaussian random vector on the [`Euclidean`](@ref) manifold `M` with
standard deviation `σ`.
"""
random_tangent(M::Euclidean, p, ::Val{:Gaussian}, σ::Float64=1.0) = σ * randn(T,manifold_dimension(M))

@doc doc"""
    randomTVector(M,x [,type=:Gaussian, σ=1.0])

return a (Gaussian) random vector from the tangent space $T_x\mathrm{Gr}(n,k)$ with mean
zero and standard deviation `σ` by projecting a random Matrix onto the  `x` with [`project`](@ref).
"""
function random_tangent(::Grassmann, p, ::Val{:Gaussian}, σ::Float64=1.0)
    Z = σ * randn(eltype(p), size(p))
    X = project_tangent(M, p, Z)
    X = X/norm(X)
	return X
end

@doc doc"""
    randomTVector(M::Hyperpolic, p)

generate a random point on the Hyperbolic manifold by projecting a point from the embedding
with respect to the Minkowsky metric.
"""
function random_tangent(M::Hyperbolic, p, ::Val{:Gaussian})
    Y = randn(eltype(p), size(p))
    X = project_tangent(M, p, Y)
    return X
end

function random_tangent(M::PowerManifold, p, options...)
    rep_size = representation_size(M.manifold)
    X = zero_tangent_vector(M, p)
    for i in get_iterator(M)
        copyto!(
            write(M, rep_size, X, i),
            random_tangent(
                M.manifold,
                _read(M, rep_size, p, i),
                options...)
        )
    end
    return X
end

@doc doc"""
    random_tangent(M::ProductManifold, x)

generate a random tangent vector in the tangent space of the point `p` on the
`ProductManifold` `M`.
"""
function random_tangent(M::ProductManifold, p, options...)
    X = map(
        (m,p) -> random_tangent(m, p, options...),
        M.manifolds,
        submanifold_components(M, p)
    )
    return X
end

@doc doc"""
    random_tangent(M::Rotations, p[, type=:Gaussian, σ=1.0])

return a random [`SOTVector`](@ref) in the tangent space
$T_x\mathrm{SO}(n)$ of the point `x` on the `Rotations` manifold `M` by generating
a random skew-symmetric matrix. The function takes the real upper triangular matrix of a
(Gaussian) random matrix $A$ with dimension $n\times n$ and subtracts its transposed matrix.
Finally, the matrix is ​​normalized.
"""
function randomTVector(M::Rotations, p, ::Val{:Gaussian}, σ::Real=1.0)
  if manifold_dimension(M)
    return zeros(1,1)
  else
    A = randn(Float64, M.dimension, M.dimension)
    A = triu(A,1) - transpose(triu(A,1))
    A = (1/norm(A))*A
    return A
  end
end

@doc doc"""
    random_tangent(M::Sphere, x[, :Gaussian, σ=1.0])

return a random tangent vector in the tangent space of `x` on the `Sphere` `M`.
"""
function random_tangent(M::Sphere, p, ::Val{:Gaussian}, σ::Float64=1.0)
    n = σ * randn( size(p) ) # Gaussian in embedding
    return n - dot(n, p)*p #project to TpM (keeps Gaussianness)
end

@doc doc"""
    random_tangent(M, p[, :Gaussian, σ = 1.0])

generate a random tangent vector in the tangent space of the point `p` on the
`SymmetricPositiveDefinite` manifold `M` by using a Gaussian distribution
with standard deviation `σ` on an ONB of the tangent space.
"""
function random_tangent(M::SymmetricPositiveDefinite, p, ::Val{:Gaussian}, σ::Float64 = 0.01)
    # generate ONB in TxM
    I = one(p)
    B = DiagonalizingOrthonormalBasis(M, I, I)
    Ξ = get_vectors(B)
    Ξx = vector_transport_to.(Ref(M), Ref(I), Ref(p), Ξ, Parallel)
    return sum( randn(length(Ξx)) .* Ξx )
end

@doc doc"""
    randomTVector(M,x [,:Gaussian,σ = 1.0])
generate a random tangent vector in the tangent space of the [`SPDPoint`](@ref)
`x` on the [`SymmetricPositiveDefinite`](@ref) manifold `M` by using a Rician distribution
with standard deviation `σ`.
"""
function randomTVector(M::SymmetricPositiveDefinite, p, ::Val{:Rician}, σ::Real = 0.01)
    # Rician
    C = cholesky( Hermitian(p) )
    R = sqrt(σ) * triu( randn(size(p,1), size(p,2)), 0)
    T = C.L * transpose(R)*R*C.U
    return log(M,x, T)
end