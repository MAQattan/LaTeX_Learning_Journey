    clc; clear;

% أسماء الخطوط
Line = ["1-2","2-3","1-4","1-5","5-6","4-3","4-6","3-7","6-7"]';

% الاستطاعة في بداية الخط
P_start = [77.2, 41.5, 185.6, 79, 40.6 , 29.8, 37.2, 15.6, 14]; % [MW]
Q_start = [93.2, 62.1, 61.3, 98.5, 62.9, -3.23, -4.11, 10.6, 8.39]; % [MVAR]

% الاستطاعة الضائعة على الخط
P_loss = [10.5, 6.77, 46.5, 13.7, 4.98, 1.85, 2.16, 0.824, 0.765]; % [MW]
Q_loss = [16, 10.3, 15.7, 20.8, 7.48, 0.362, 0.425, 0.161, 0.149]; % [MVAR]

% الجهد عند نهاية الخط (kV)
U_end = [102, 85.23, 90.65, 97.24, 85.53, 85.23, 85.53, 81.74, 81.74];

% مقاومات الخطوط (Ohm)
R = [10.5, 12.6, 17.8, 12.6, 8.4, 16.9, 12.7, 16.9, 21.1];

% الاستطاعة في نهاية الخط
P_end = P_start - P_loss;
Q_end = Q_start - Q_loss;

% ===== حساب المؤشرات =====
lambda_p = (2 .* P_end .* R) ./ (U_end.^2);
lambda_q = (2 .* Q_end .* R) ./ (U_end.^2);

% ===== عرض النتائج =====
Results = table(Line, lambda_p', lambda_q', ...
    'VariableNames', {'Line','λ′','λ″'});

disp(Results)



%% ===== حساب مؤشرات العقد =====

% تعريف المسارات من العقدة 1
% كل مسار عبارة عن أرقام الخطوط (حسب ترتيب Line)

Paths = {
    [1];            % عقدة 2 : 1-2
    [1 2];          % عقدة 3 : 1-2-3
    [3];            % عقدة 4 : 1-4
    [4];            % عقدة 5 : 1-5
    [4 5];          % عقدة 6 : 1-5-6
    [1 2 8];        % عقدة 7 : 1-2-3-7
};

NodeNames = ["Bus-2","Bus-3","Bus-4","Bus-5","Bus-6","Bus-7"]';

lambda_node_p = zeros(length(Paths),1);
lambda_node_q = zeros(length(Paths),1);

for i = 1:length(Paths)
    lambda_node_p(i) = sum(lambda_p(Paths{i}));
    lambda_node_q(i) = sum(lambda_q(Paths{i}));
end

%% ===== معالجة نقاط التفرع =====

% عقدة 3 لها مساران: (1-2-3) و (1-4-3)
lambda_3_p = mean([
    lambda_p(1) + lambda_p(2);   % 1-2-3
    lambda_p(3) + lambda_p(6)    % 1-4-3
]);

lambda_3_q = mean([
    lambda_q(1) + lambda_q(2);
    lambda_q(3) + lambda_q(6)
]);

% استبدال القيمة السابقة لعقدة 3
idx = find(NodeNames == "Bus-3");
lambda_node_p(idx) = lambda_3_p;
lambda_node_q(idx) = lambda_3_q;

NodeResults = table(NodeNames, lambda_node_p, lambda_node_q, ...
    'VariableNames', {'Node','λ′_node','λ″_node'});

disp(NodeResults)
