function mechParamsMLR = computeParamsMultilin_wedge(f0,rho, coeffsTable, MLRIdxs)
% coeffs - intercept - rho - Ex - Ey - Ez - Gxy - Gyz - Gxz

    coeffs = table2array(coeffsTable);
    f0Names = coeffsTable.Properties.RowNames;
    paramsNames = coeffsTable.Properties.VariableNames;

    intercepts = coeffs(:,1);
    rho_coeffs = coeffs(:,2);

    Ex_coeffs  = coeffs(:,3);
    Ey_coeffs  = coeffs(:,4);
    Gxy_coeffs = coeffs(:,6);
    Gyz_coeffs = coeffs(:,7);
    Gxz_coeffs = coeffs(:,8);

    B = f0(:) - intercepts(MLRIdxs) -rho_coeffs(MLRIdxs)*rho;
    % X = [         Ex                    Ey                        Gxy                       Gyz                     Gxz             ]
%     A = [           0                      0               Gxy_coeffs(MLRIdxs(1))              0             Gxz_coeffs(MLRIdxs(1)); ...
%           Ex_coeffs(MLRIdxs(2))            0                         0                         0             Gxz_coeffs(MLRIdxs(2)); ...
%                     0              Ey_coeffs(MLRIdxs(3))             0               Gyz_coeffs(MLRIdxs(3))           0            ; ...
%           Ex_coeffs(MLRIdxs(4))            0               Gxy_coeffs(MLRIdxs(4))    Gyz_coeffs(MLRIdxs(4))  Gxz_coeffs(MLRIdxs(4)); ...
%                     0              Ey_coeffs(MLRIdxs(5))   Gxy_coeffs(MLRIdxs(5))    Gyz_coeffs(MLRIdxs(5))  Gxz_coeffs(MLRIdxs(5));  ];

    A = [Ex_coeffs(MLRIdxs) Ey_coeffs(MLRIdxs) Gxy_coeffs(MLRIdxs) Gyz_coeffs(MLRIdxs) Gxz_coeffs(MLRIdxs)];

    X = linsolve(A,B);
    X = X(:).';
    mechParamsMLR = array2table(X, 'VariableNames', paramsNames([3,4,6,7,8]));
end