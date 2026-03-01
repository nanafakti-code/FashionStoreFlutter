-- 1. TABLA DE CUPONES (DEFINICIONES)
CREATE TABLE public.coupons (
  id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  code VARCHAR(50) UNIQUE NOT NULL, -- Ej: "VERANO2026"
  description TEXT,
  discount_type VARCHAR(20) NOT NULL CHECK (discount_type IN ('PERCENTAGE', 'FIXED')),
  value NUMERIC(10, 2) NOT NULL CHECK (value > 0), -- Valor del descuento (ej: 10% o 10€)
  min_order_value NUMERIC(10, 2), -- Mínimo de compra para aplicar (opcional)
  max_uses_global INT, -- Límite total de usos del cupón (NULL = infinito)
  max_uses_per_user INT DEFAULT 1, -- Límite de veces que 1 usuario puede usarlo
  expiration_date TIMESTAMP WITH TIME ZONE NOT NULL,
  is_active BOOLEAN DEFAULT TRUE,
  assigned_user_id UUID REFERENCES auth.users(id), -- Si es NULL, es para todos. Si tiene ID, es exclusivo.
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. TABLA DE USOS (HISTORIAL)
-- Se usa para contar cuántas veces se ha usado un cupón y validar límites
CREATE TABLE public.coupon_usages (
  id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  coupon_id BIGINT NOT NULL REFERENCES public.coupons(id),
  user_id UUID NOT NULL REFERENCES auth.users(id),
  order_id UUID, -- ID del pedido donde se usó
  discount_amount NUMERIC(10, 2), -- Cuánto dinero se descontó realmente
  used_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Índices para búsqueda rápida en validaciones
CREATE INDEX idx_coupons_code ON public.coupons(code);
CREATE INDEX idx_coupon_usages_check ON public.coupon_usages(coupon_id, user_id);
