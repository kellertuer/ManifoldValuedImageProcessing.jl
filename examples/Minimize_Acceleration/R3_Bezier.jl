@doc raw"""
# Minimize the acceleration of a composite Bézier curve on $\mathbb R^3$ with interpolation

This example appeared in Sec. 5.2, second example, of
> R. Bergmann, P.-Y. Gousenbourger: _A variational model for data fitting on manifolds
> by minimizing the acceleration of a Bézier curve_.
> Frontiers in Applied Mathematics and Statistics, 2018.
> doi: [10.3389/fams.2018.00059](https://dx.doi.org/10.3389/fams.2018.00059)
"""
#
# Load Manopt and required packages
#
using Manopt, Manifolds, Colors, ColorSchemes, Makie
asyExport = true #export data and results to asyExport
λ = 50.0

curve_samples = [range(0,3,length=1601)...] # sample curve for the gradient
curve_samples_plot = [range(0,3,length=1601)...] # sample curve for asy exports

experimentFolder = "examples/Minimize_Acceleration/R3_Bezier/"
experimentName = "Bezier_R3_Approximation"

sColor = RGBA{Float64}(colorant"#BBBBBB")
dColor = RGBA{Float64}(colorant"#EE7733") # data Color: Tol Vibrant Orange
pColor = RGBA{Float64}(colorant"#0077BB") # control point data color: Tol Virbant Blue
ξColor = RGBA{Float64}(colorant"#33BBEE") # tangent vector: Tol Vibrant blue
bColor = RGBA{Float64}(colorant"#009988") # inner control points: Tol Vibrant teal
#
# Data
#
M = Euclidean(3)
p0 = [0.0, 0.0, 1.0]
p1 = [0.0, -1.0, 0.0]
p2 = [-1.0, 0.0, 0.0]
p3 = 1/sqrt(82)*[0.0, -1.0, -9.0]
t0p = π/(8 * sqrt(2)) * [1.0, -1.0, 0.0];
t1p = -π/(4 * sqrt(2)) * [1.0, 0.0, 1.0];
t2p = π/(4 * sqrt(2)) * [0.0, 1.0, -1.0];
t3m = π/8 * [-1.0, 0.0, 0.0]

B = [   (p0, exp(M, p0, t0p), exp(M, p1, -t1p), p1),
        (p1, exp(M, p1, t1p), exp(M, p2, -t2p), p2),
        (p2, exp(M, p2, t2p), exp(M, p3, t3m), p3),
    ]

cP = de_casteljau(M,B,curve_samples_plot)
cPmat = hcat([[b...] for b in cP]...)
scene = lines(cPmat[1,:], cPmat[2,:], cPmat[3,:])
scatter!(scene,
    [p0[1], p1[1], p2[1], p3[1]],
    [p0[2], p1[2], p2[2], p3[2]],
    [p0[3], p1[3], p2[3], p3[3]],
    color = pColor
    )
dataP = get_bezier_junctions(M,B)
tup2mat(B) = hcat([[b...] for b in B]...)
mat2tup(matB) = [Tuple(matB[:,i]) for i=1:size(matB,2)]
matB = tup2mat(B)
N = PowerManifold(M, NestedPowerRepresentation(), size(matB)...)
F(matB) = cost_L2_acceleration_bezier(M, mat2tup(matB), curve_samples,λ,dataP)
∇F(matB) = tup2mat(∇L2_acceleration_bezier(M, mat2tup(matB), curve_samples,λ,dataP))
x0 = matB
Bmat_opt = steepest_descent(N, F, ∇F, x0;
    stepsize = ArmijoLinesearch(1.0,ExponentialRetraction(),0.5,0.0001), # use Armijo lineSearch
    stopping_criterion = StopWhenAny(StopWhenChangeLess(10.0^(-15)),
                                    StopWhenGradientNormLess(10.0^-5),
                                    StopAfterIteration(300),
                                ),
    debug = [:Stop, :Iteration," | ",
        :Cost, " | ", DebugGradientNorm(), " | ", DebugStepsize(), " | ", :Change, "\n"]
)
B_opt = mat2tup(Bmat_opt)
res_cp = get_bezier_junctions(M, B_opt)
res_curve = de_casteljau(M,B_opt,curve_samples_plot)
resPmat = hcat([[b...] for b in res_curve]...)

lines!(scene, resPmat[1,:], resPmat[2,:], resPmat[3,:], color = ξColor, linewidth = 1.5)
scatter!(scene,
    [res_cp[1][1], res_cp[2][1], res_cp[3][1], res_cp[4][1]],
    [res_cp[1][2], res_cp[2][2], res_cp[3][2], res_cp[4][2]],
    [res_cp[1][3], res_cp[2][3], res_cp[3][3], res_cp[4][3]],
    color = dColor
    )