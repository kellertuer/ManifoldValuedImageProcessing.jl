using Manopt, Manifolds, ManifoldsBase, Random, LinearAlgebra, BenchmarkTools
Random.seed!(42)
import Manifolds: vector_transport_to!

function run_rayleigh_minimization(n::Int)
    A = randn(n, n)
    A = (A + A') / 2
    F(::Sphere, p::Array{Float64,1}) = p' * A * p
    gradF(::Sphere, p::Array{Float64,1}) = 2 * (A * p - p * p' * A * p)
    function HessF(::Sphere, p::Array{Float64,1}, X::Array{Float64,1})
        return 2 * (A * X - p * p' * A * X - X * p' * A * p - p * p' * X * p' * A * p)
    end
    M = Sphere(n - 1)
    x = random_point(M)
    return trust_regions!(
        M,
        F,
        gradF,
        ApproxHessianSymmetricRankOne(M, x, gradF; nu=eps(Float64)^2),
        x;
        stopping_criterion=StopWhenAny(
            StopAfterIteration(100),
            StopWhenGradientNormLess(norm(M, x, gradF(M, x)) * 10^(-6)),
        ),
        max_trust_region_radius=8.0,
        debug=[
            :Iteration, " ", :Cost, " | ", DebugEntry(:trust_region_radius), "\n", 1, :Stop
        ],
    ),
    trust_regions!(
        M,
        F,
        gradF,
        HessF,
        x;
        stopping_criterion=StopWhenAny(
            StopAfterIteration(500),
            StopWhenGradientNormLess(norm(M, x, gradF(M, x)) * 10^(-6)),
        ),
        max_trust_region_radius=8.0,
        debug=[
            :Iteration, " ", :Cost, " | ", DebugEntry(:trust_region_radius), "\n", 1, :Stop
        ],
    )
end
io = IOBuffer()

for n in [100]
    b = @benchmark run_rayleigh_minimization($n) samples = 30
    show(io, "text/plain", b)
    s = String(take!(io))
    println("Benchmarking $(n):\n", s, "\n\n")
end
