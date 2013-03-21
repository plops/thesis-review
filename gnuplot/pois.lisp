;; richard fatemans code
(defun k (n m)
  (if (<= n m)
      n
      (*
       (k n (* 2 m))
       (k (- n m) (* 2 m)))))

(defun factorial (n)
  (if (zerop n)
      1
      (k n 1)))

(defun pois (k lambd)
  (* (exp (- lambd))
     (/ (expt lambd k) (factorial k))))



(with-open-file (s "pois.dat" :direction :output
		   :if-exists :supersede
		   :if-does-not-exist :create)
  (format s "~{~{~a ~}~%~}"
   (loop for k below 40 collect
	(list k
	      (pois k 3/10)
	      (pois k 3)
	      (pois k 30)))))
